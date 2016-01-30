module ActiveRecordFlorder

  # Handle configuration loading and storing
  # defines getters for configurable attributes
  module Configurable

    # Uses instance class variables
    module ClassMethods
      def florder_direction
        @florder_config[:type]
      end

      def position_attr_name
        @florder_config[:attribute] || ActiveRecordFlorder.get_attribute
      end

      def position_scope_attr
        @florder_config[:scope] || ActiveRecordFlorder.get_scope
      end

      def min_position_delta
        @florder_config[:min_delta] || ActiveRecordFlorder.get_min_delta
      end

      def next_position_step
        @florder_config[:step] || ActiveRecordFlorder.get_step
      end

      def return_all_affected_by_move
        @florder_config[:populate] || ActiveRecordFlorder.get_populate
      end
    end

    # All instance methods are just proxy
    # To Class Methods
    def florder_direction
      self.class.florder_direction
    end

    def position_attr_name
      self.class.position_attr_name
    end

    def position_scope_attr
      self.class.position_scope_attr
    end

    def min_position_delta
      self.class.min_position_delta
    end

    def next_position_step
      self.class.next_position_step
    end

    def return_all_affected_by_move
      self.class.return_all_affected_by_move
    end
  end
end
