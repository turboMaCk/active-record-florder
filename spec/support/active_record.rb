require 'active_record'
require 'active_record_tasks'
require 'yaml'

config = ActiveRecordTasks.config
config.db_dir ||= 'db'
config.db_config_path ||= File.join(config.db_dir, 'config.yml')
config.env ||= 'test'

settings = YAML.load_file(config.db_config_path)[config.env]

ActiveRecord::Base.establish_connection(settings)
