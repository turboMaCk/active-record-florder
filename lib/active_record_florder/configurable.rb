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
        @florder_config[:attribute] || ActiveRecordFlorder.attribute
      end

      def position_scope_attr
        @florder_config[:scope] || ActiveRecordFlorder.scope
      end

      def min_position_delta
        @florder_config[:min_delta] || ActiveRecordFlorder.min_delta
      end

      def next_position_step
        @florder_config[:step] || ActiveRecordFlorder.step
      end

      def return_all_affected_by_move
        @florder_config[:return_all_affected] || ActiveRecordFlorder.return_all_affected
      end
    end

    # All instance methods are delegated to their class methods
    delegate :florder_direction,
             :position_attr_name,
             :position_scope_attr,
             :min_position_delta,
             :next_position_step,
             :return_all_affected_by_move,
             to: :class
  end
end
