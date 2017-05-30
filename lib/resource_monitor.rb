require 'pathname'

module RedmineResourceMonitor
  def self.root
    @root ||= Pathname.new File.expand_path('..', File.dirname(__FILE__))
  end

  def self.config
    config_yml = File.read(self.root.join('config', 'configuration.yml'))
    @config ||= YAML.load(config_yml)['resource_monitor']
  end
end

# Load patches for Redmine
Rails.configuration.to_prepare do
  Dir[RedmineResourceMonitor.root.join('app/patches/**/*_patch.rb')].each { |f| require_dependency f }
end

require_relative 'dispatcher'
