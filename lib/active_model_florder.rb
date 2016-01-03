require 'active_model_florder/error'
require 'active_model_florder/configurable'
require 'active_model_florder/base'
require 'active_model_florder/desc'
require 'active_model_florder/asc'

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
      :owner_id
    end

    def min_position_delta
      0.0005
    end

    def next_position_step
      2**16
    end
  end
end
