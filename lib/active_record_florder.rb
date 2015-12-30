require 'active_record'
require 'active_record_florder/error'
require 'active_record_florder/configurable'
require 'active_record_florder/base'
require 'active_record_florder/models'
require 'active_record_florder/version'

# ActiveModelFlorder
# Floating point ActiveRecord models ordering for rich client apps
# heavily inspirated by Trello's ordering alorithm.
# DOC: https://github.com/turboMaCk/active-record-florder
module ActiveRecordFlorder
  class << self

    # Configure method can be used from initializer
    # ActiveRecordFlorder.confige do |config|
    #   config.{attribute} {value}
    # end
    def configure
      yield self if block_given?
    end

    # DB column name
    def attribute(value)
      @attribute = value
    end

    def get_attribute
      @attribute || :position
    end

    # Position scope
    def scope(value)
      @scope = value
    end

    def get_scope
      @scope || nil
    end

    # Minimal allowed delata between positions
    def min_delta(value)
      @min_delta = value
    end

    def get_min_delta
      @min_delta || 0.0005
    end

    # Optimal and initial delta between positions
    def step(value)
      @step = value
    end

    def get_step
      @step || 2**16
    end
  end
end

# Extending ActiveRecord::Base with florder method
ActiveRecord::Base.extend ActiveRecordFlorder::Models
