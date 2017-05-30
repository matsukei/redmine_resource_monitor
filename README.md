# Redmine resource monitor plugin(Work in Progress)

Resource monitoring (Memory / CPU utilization / Load average)

## Usage

It works in one of the following ways.

1. Execution via Passenger's process
  * PassengerMinInstances is required over 1 (default 1).
  * You can change `config\configuration.yml` to specify the desired execution interval (default 15 minutes).
2. Execution of Rake task via cron
  * Please change `resoruces.method` of `config\configuration.yml` to `cron`.
  * Please define to execute the following Rake task.
    * `bundle exec rake redmine:monitor RAILS_ENV=production`

## Screenshot

## Unimplemented

* Sending Alert Mail
* Test

## Tested environments

* CentOS 6 and 7
* Redmine 3.3.2.stable and 3.2.5.stable
* Ruby 2.3 and 2.2
* Passenger 5.1.2 and 5.0.21

## Install

1. git clone or copy an unarchived plugin to plugins/redmine_resource_monitor on your Redmine path.
2. `$ cd your_redmine_path`
3. `$ bundle install`
4. `$ bundle exec rake redmine:plugins:migrate NAME=redmine_resource_monitor RAILS_
ENV=production`
5. web service restart

## Uninstall

1. `$ cd your_redmine_path`
2. `$ rvmsudo bundle exec rake redmine:plugins:migrate NAME=redmine_resource_monitor RAILS_ENV=production VERSION=0`
3. remove plugins/redmine_resource_monitor
4. web service restart

## Dependency

Chart: https://github.com/plotly/plotly.js/

> ![Browser to can display charts ](https://plot.ly/gh-pages/documentation/static//images/browser_support.png)
>
> plotly.js runs on all SVG-compatible browsers

## License

[The MIT License](https://opensource.org/licenses/MIT)
