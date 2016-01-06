require 'active_record'
require 'active_record_tasks'

# TODO: load from config
config = ActiveRecordTasks.config
config.db_dir ||= 'db'
config.db_config_path ||= File.join(config.db_dir, 'config.yml')
config.env ||= 'test'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/active-model-florder_test.sqlite3'
)
