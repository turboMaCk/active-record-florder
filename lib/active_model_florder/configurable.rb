module ActiveModelFlorder
  module Configurable

    module ClassMethods
      def position_attr_name
        ActiveModelFlorder.position_attr_name
      end

      def position_scope_attr
        ActiveModelFlorder.position_scope_attr
      end

      def min_position_delta
        ActiveModelFlorder.min_position_delta
      end
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
      ActiveModelFlorder.next_position_step
    end
  end
end
