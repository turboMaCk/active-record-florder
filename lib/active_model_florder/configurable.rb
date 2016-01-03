module ActiveModelFlorder
  module Configurable

    module ClassMethods
      def florder_direction
        @florder_config[:type]
      end

      def position_attr_name
        @florder_config[:attr] || ActiveModelFlorder.position_attr_name
      end

      def position_scope_attr
        @florder_config[:scope] || ActiveModelFlorder.position_scope_attr
      end

      def min_position_delta
        @florder_config[:min_delta] || ActiveModelFlorder.min_position_delta
      end

      def next_position_step
        @florder_config[:step] || ActiveModelFlorder.next_position_step
      end
    end

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
  end
end
