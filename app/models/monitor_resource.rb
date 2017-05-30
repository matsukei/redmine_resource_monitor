class MonitorResource < ActiveRecord::Base
  unloadable

  has_many :monitor_processes

  scope :extract_range_of_date, lambda { |display_time|
    where('created_at >= ?', display_time.beginning_of_day).
    where('created_at <= ?', display_time.end_of_day).order(:created_at)
  }
end
