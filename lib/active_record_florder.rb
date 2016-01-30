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

    attr_writer(:attribute, :min_delta, :step, :return_all_affected)
    attr_accessor(:scope)

    def attribute
      @attribute || :position
    end

    def min_delta
      @min_delta || 0.0005
    end

    def step
      @step || 2**16
    end

    def return_all_affected
      @return_all_affected || false
    end

    # Configure method can be used from initializer
    # ActiveRecordFlorder.confige do |config|
    #   config.{attribute} {value}
    # end
    def configure
      yield self if block_given?
    end
  end
end

# Extending ActiveRecord::Base with florder method
ActiveRecord::Base.extend ActiveRecordFlorder::Models
