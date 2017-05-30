class ResourceMonitorsController < ApplicationController
  unloadable

  layout 'admin'
  before_filter :require_admin

  include ResourceMonitorsHelper

  def index
    time_zone = User.current.time_zone.try(:name) || 'UTC'

    @settings = Setting['plugin_redmine_resource_monitor']
    @display_time = (params[:display_date].to_s.to_time || Time.now).in_time_zone(time_zone)
    @monitor_resources = MonitorResource.extract_range_of_date(@display_time)

    time_line = @monitor_resources.pluck(:created_at).map do |at|
      at.in_time_zone(time_zone).strftime('%Y-%m-%d %H:%M')
    end

    respond_to do |format|
      format.html {
        # See: https://plot.ly/javascript/
        create_memory_chart(time_line)
        create_cpu_chart(time_line)
        create_usage_chart(time_line)
        create_load_average_chart(time_line)
        create_server_user_chart(time_line)
      }

      format.csv  {
        send_data(report_to_csv(@monitor_resources, time_line), :type => 'text/csv; header=present',
          :filename => "#{@display_time.strftime('%Y%m%d')}_monitor_resources.csv")
      }
    end
  end

end
