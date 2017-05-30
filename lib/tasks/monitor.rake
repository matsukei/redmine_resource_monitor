desc "Server resource monitoring(use command: free and ps)"
namespace :redmine do
  task monitor: :environment do
    RedmineResourceMonitor::Agent.resoruces_monitor
  end
end
