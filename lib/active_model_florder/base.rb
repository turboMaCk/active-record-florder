require 'active_support'

module ActiveModelFlorder
  # Doc will come here
  module Base
    extend ActiveSupport::Concern

    included do
      extend ActiveModelFlorder::Configurable::ClassMethods
      include ActiveModelFlorder::Configurable

      before_create -> { push(:highest) }

      # scoped ordered items by POSITION_SCOPE_ATTR eg. user_id, folder_id ...
      scope :position_scope, lambda { |value|
        return default_scoped if position_scope_attr.empty?
        where(position_scope_attr.to_sym => value)
      }
    end

    def move(position)
      position.to_f

      fail ActiveModelFlorder::Error, "Position param is required" unless position
      fail ActiveModelFlorder::Error, "Position should be > 0" unless (normalized_position = normalize_position(position)) > 0
      ensure_position_solving(position, normalized_position)

      if new_record?
        self[position_attr_name.to_sym] = normalized_position
      else
        update_attribute(position_attr_name.to_sym, normalized_position)
      end

      self
    end

    protected

    def slide(direction)
      sibling_position = get_sibling(direction).try(position_attr_name.to_sym)

      if sibling_position
        move((send(position_attr_name.to_sym) + sibling_position) / 2.0)
      else
        push(direction == :increase ? :highest : :lowest)
      end
    end

    private

    def push(place)
      return move(next_position_step) unless self.class.position_scope(scope_value).any?

      sibling_position = get_sibling(place).try(position_attr_name.to_sym)

      position = calc_push_position(place, sibling_position)
      move(position)
    end

    def calc_push_position(place, sibling_position)
      case place
      when :highest
        sibling_position + next_position_step
      when :lowest
        sibling_position / 2.0
      end
    end

    # Find all models with conflicting position and solve conflicts
    def ensure_position_solving(position, normalized_position)
      min = normalized_position - min_position_delta
      max = normalized_position + min_position_delta

      conflicts = self.class.position_scope(scope_value)
                  .where("#{position_attr_name} > ? AND #{position_attr_name} < ?", min, max)
                  .where.not(id: id)
                  .order(:position)

      position_conflict_solver(conflicts, position) if conflicts.present?
    end

    def get_sibling(place)
      conditions = get_siblings_conditions(place)

      self.class.position_scope(scope_value)
        .where(conditions.first)
        .order(conditions.last)
        .limit(1).first
    end

    def get_siblings_conditions(place)
      case place
      when :increase
        [["#{position_attr_name} > ?",
          send(position_attr_name.to_sym)],
         "#{position_attr_name} DESC"]
      when :decrease
        [["#{position_attr_name} < ?",
          send(position_attr_name.to_sym)],
         "#{position_attr_name} ASC"]
      when :highest
        [nil,
         "#{position_attr_name} DESC"]
      when :lowest
        [nil,
         "#{position_attr_name} ASC"]
      else
        error_message = "Place param '#{place}' is not one of: increase, decrease, highest, lowest."
        fail ActiveModelFlorder::Error, error_message
      end
    end

    # returns normalized position (positive rounded value)
    def normalize_position(position)
      position.round(min_position_delta.to_s.split('.').last.size)
    end

    # Scope helper
    # returns value of scope attr
    def scope_value
      send(position_scope_attr)
    end
  end
end
