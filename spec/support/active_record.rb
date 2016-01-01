require 'active_record'

# TODO: load from config
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/active-model-florder_test.sqlite3'
)
