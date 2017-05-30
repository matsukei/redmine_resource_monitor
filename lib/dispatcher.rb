require_relative 'agent'

module RedmineResourceMonitor
  class Dispatcher

    class << self
      def starting
        agent = RedmineResourceMonitor::Agent.instance
        agent.execute if agent.via_process? && !agent.running?
      end

      def stopping
      end
    end

  end
end

# Passenger
if defined?(PhusionPassenger)
  require_dependency 'dispatchers/passenger'

  RedmineResourceMonitor::Dispatchers::Passenger.tap do |mod|
    RedmineResourceMonitor::Dispatcher.send(:include, mod) unless RedmineResourceMonitor::Dispatcher.include?(mod)
  end
end

# Unicorn
### TODO
