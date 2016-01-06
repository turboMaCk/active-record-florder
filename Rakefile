require "active_record_tasks"
require "bundler/gem_tasks"
require "rspec/core/rake_task"

ActiveRecordTasks.configure do |config|
  # These are all the default values
  config.db_dir = 'db'
  config.db_config_path = 'db/config.yml'
  config.env = 'test'
end

begin
  # Run this AFTER you've configured
  ActiveRecordTasks.load_tasks

  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
  # no rspec available
end
