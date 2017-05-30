require 'singleton'
require 'open3'

module RedmineResourceMonitor
  class Agent
    include Singleton

    class << self
      def resoruces_monitor
        free_out, free_error, free_status = Open3.capture3('free -m')
        uptime_out, uptime_error, uptime_status = Open3.capture3('uptime')
        ps_out, ps_error, ps_status = Open3.capture3('ps aux')
        return false unless free_status.success? && uptime_status.success? && ps_status.success?

        users = uptime_out =~ /(\d+)\suser/ && $1.to_i
        load_average = uptime_out =~ /load\saverage:\s(\d+\.\d+)/ && $1.to_f

        memories = []
        free_out.each_line.with_index do |memory, n|
          next if n.zero?
          memories << memory.split(' ').compact
        end
        buffers_chache = memories.size == 3 ? memories[1] : memories.first

        processes = []
        ps_out.each_line.with_index do |process, n|
          next if n.zero?
          process = process.split(' ').compact
          command_path = process[10..(process.size - 1)].join(' ')
          command = command_path.gsub(/\s\-.+/, '').gsub(/\A\/.+\//, '')
          command = command_path if command.blank?

          processes << process[0..9] + [ command ]
        end

        cpu_used = processes.inject(0.0) { |sum, process| sum + process[2].to_f }
        commands = processes.group_by { |process| process.last }

        monitor_processes = []
        commands.each do |command, records|
          next if command =~ /\A\[.+\]\z/

          cpu = records.inject(0.0) { |sum, process| sum + process[2].to_f }
          memory = records.inject(0.0) { |sum, process| sum + process[5].to_i.kilobytes }
          monitor_processes << {
            cpu: cpu,
            memory: memory,
            count: records.count,
            command: command
          }
        end

        top_5_cpu_usage_commands = monitor_processes.sort_by { |process| process[:cpu] }.reverse.slice(0, 5).map { |process| process[:command] }
        top_5_mem_usage_commands = monitor_processes.sort_by { |process| process[:memory] }.reverse.slice(0, 5).map { |process| process[:command] }
        top_5_resource_usage_commands = (top_5_cpu_usage_commands + top_5_mem_usage_commands).uniq

        begin
          ActiveRecord::Base.transaction do
            monitor_resource = MonitorResource.new(
              memory_total: memories.first[1],
              memory_used: buffers_chache[2],
              cpu_used: cpu_used,
              logged_in_users: users,
              last_load_average: load_average)

            monitor_processes.each do |monitor_process|
              next unless top_5_resource_usage_commands.include?(monitor_process[:command])
              monitor_resource.monitor_processes.build(monitor_process)
            end

            monitor_resource.save!
          end

          return true
        rescue => e
          Rails.logger.error e.message
          return false
        end

      end
    end

    def initialize
      @config = RedmineResourceMonitor.config['resoruces'] || {}
      @timer_task = self.initialize_timer_task
    end

    def config
      @config
    end

    def via_process?
      config['method'].downcase == 'agent'
    end

    def interval_minutes
      min = config['interval_minutes'].to_i
      min.zero? ? 15 : min
    end

    def timeout_seconds
      sec = config['timeout_seconds'].to_i
      sec.zero? ? 300 : sec
    end

    def interval
      now = Time.now
      ((self.interval_minutes - 1) - (now.min % self.interval_minutes)).minutes + (60 - now.sec).seconds
    end

    def initialize_timer_task
      Concurrent::TimerTask.new(execution_interval: self.interval,
        timeout_interval: self.timeout_seconds) do |task|

        task.execution_interval = self.interval
        self.class.resoruces_monitor
      end
    end

    def execute
      @timer_task.execute
    end

    def running?
      @timer_task.running?
    end

  end
end
