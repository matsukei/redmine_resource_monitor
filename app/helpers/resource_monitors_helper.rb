module ResourceMonitorsHelper

  def create_memory_chart(time_line)
    memory_used = @monitor_resources.pluck(:memory_used)
    memory_total = @monitor_resources.pluck(:memory_total)

    gon.memory_chart = {
      data: [
        { x: time_line, y: memory_used, name: 'Used' },
        { x: time_line, y: memory_total, name: 'Total' }
      ],
      layout: {
        title: l(:label_memory_chart)
      },
      option: {}
    }
  end

  def create_cpu_chart(time_line)
    cpu_used = @monitor_resources.pluck(:cpu_used)

    gon.cpu_chart = {
      data: [
        { x: time_line, y: cpu_used, name: 'Used' }
      ],
      layout: {
        title: l(:label_cpu_chart)
      },
      option: {}
    }
  end

  def create_usage_chart(time_line)
    # without kernel command
    monitor_processes = MonitorProcess.where(monitor_resource_id: @monitor_resources.pluck(:id))
    command_names = monitor_processes.pluck(:command).uniq

    cpu_usage_datas = []
    mem_usage_datas = []
    @monitor_resources.each do |monitor_resource|
      monitor_processes = monitor_resource.monitor_processes
      command_names.each_with_index do |command_name, i|
        cpu_usage_datas[i] ||= []
        mem_usage_datas[i] ||= []

        processes = monitor_processes.where(command: command_name)
        cpu_usage_datas[i] << processes.sum(:cpu)
        mem_usage_datas[i] << processes.sum(:memory)
      end
    end

    cpu_usage_chart_data = []
    mem_usage_chart_data = []
    command_names.each_with_index do |command_name, i|
      cpu_usage_chart_data << { x: time_line, y: cpu_usage_datas[i], name: command_name, type: 'bar' }
      mem_usage_chart_data << { x: time_line, y: mem_usage_datas[i], name: command_name, type: 'bar' }
    end

    cpu_usage_chart_data.sort_by! { |chart_data| chart_data[:y].sum }
    mem_usage_chart_data.sort_by! { |chart_data| chart_data[:y].sum }

    gon.cpu_usage_chart = {
      data: cpu_usage_chart_data.reverse.slice(0, 5),
      layout: {
        barmode: 'stack',
        title: l(:label_cpu_usage_chart)
      },
      option: {}
    }

    gon.memory_usage_chart = {
      data: mem_usage_chart_data.reverse.slice(0, 5),
      layout: {
        barmode: 'stack',
        title: l(:label_memory_usage_chart)
      },
      option: {}
    }
  end

  def create_load_average_chart(time_line)
    load_average = @monitor_resources.pluck(:last_load_average)

    gon.load_average_chart = {
      data: [
        { x: time_line, y: load_average, name: 'Used' }
      ],
      layout: {
        title: l(:label_load_average_chart)
      },
      option: {}
    }
  end

  def create_server_user_chart(time_line)
    user = @monitor_resources.pluck(:logged_in_users)

    gon.server_user_chart = {
      data: [
        { x: time_line, y: user, name: 'User' }
      ],
      layout: {
        title: l(:label_server_user_chart)
      },
      option: {}
    }
  end

  def report_to_csv(monitor_resources, time_line)
    Redmine::Export::CSV.generate do |csv|
      csv << [ '' ] + time_line
      csv << [ l(:label_cpu_chart) ] + monitor_resources.pluck(:cpu_used)
      csv << [ l(:label_memory_chart) ] + monitor_resources.pluck(:memory_used)
      csv << [ l(:label_load_average_chart) ] + monitor_resources.pluck(:last_load_average)
      csv << [ l(:label_server_user_chart) ] + monitor_resources.pluck(:logged_in_users)
    end
  end

end
