Redmine::Plugin.register :redmine_resource_monitor do
  name 'Redmine Resource Monitor plugin'
  author 'Matsukei Co.,Ltd'
  description 'monitors the status of Rake server processes and server resources'
  version '0.8.0'
  url 'https://github.com/matsukei/redmine_resource_monitor'
  author_url 'http://www.matsukei.co.jp/'

  menu :admin_menu, :resource_monitors, {
      controller: 'resource_monitors', action: 'index'
    }, caption: :label_resource_monitor,
    html: { class: 'icon report icon-report' }, if: Proc.new { User.current.admin? }

  settings(partial: 'resource_monitors/settings',
    default: {
      visibled_resource_charts: [
        'cpu_chart', 'cpu_usage_chart',
        'memory_chart', 'memory_usage_chart',
        'load_average_chart', 'server_user_chart'
      ]
    })

end

require_relative 'lib/resource_monitor'
