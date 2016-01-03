require 'active_record'
require 'active_model_florder/error'
require 'active_model_florder/configurable'
require 'active_model_florder/base'
require 'active_model_florder/models'

# doc
module ActiveModelFlorder
  class << self
    def configure
      yield self if block_given?
    end

    def position_attr_name
      :position
    end

    def position_scope_attr
      nil
    end

    def min_position_delta
      0.0005
    end

    def next_position_step
      2**16
    end
  end
end

ActiveRecord::Base.extend ActiveModelFlorder::Models
