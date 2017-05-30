module RedmineResourceMonitor
  module Dispatchers
    module Passenger
      unloadable

      extend ActiveSupport::Concern

      included do
        PhusionPassenger.on_event(:starting_worker_process) do |forked|
          self.starting
        end

        PhusionPassenger.on_event(:stopping_worker_process) do
          self.stopping
        end
      end

    end
  end
end
