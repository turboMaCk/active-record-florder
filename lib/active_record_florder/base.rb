require 'active_support'

module ActiveRecordFlorder
  # Doc will come here
  module Base
    extend ActiveSupport::Concern

    included do
      extend ActiveRecordFlorder::Configurable::ClassMethods
      include ActiveRecordFlorder::Configurable

      before_create -> { push(:highest) }

      # scoped ordered items by POSITION_SCOPE_ATTR eg. user_id, folder_id ...
      scope :position_scope, lambda { |value|
        return default_scoped unless position_scope_attr
        where(position_scope_attr.to_sym => value)
      }

      scope :ordered, lambda {
        direction = florder_direction.to_sym == :desc ? 'DESC' : 'ASC'
        order("#{position_attr_name} #{direction}")
      }
    end

    def move(position)
      position.to_f

      fail ActiveRecordFlorder::Error, 'Position param is required' unless position
      fail ActiveRecordFlorder::Error, 'Position should be > 0' unless (normalized_position = normalize_position(position)) > 0
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
        move((send(position_attr_name.to_sym) + min_position_delta))
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

    def position_conflict_solver(conflicts, position)
      conflicts.each do |conflict|
        conflict_position = conflict.send(position_attr_name.to_sym)
        direction = get_conflict_direction(position, conflict_position)
        conflict.slide(direction)
      end
    end

    def get_conflict_direction(position, conflict_position)
      conflict_position > position ? :increase : :decrease
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
        fail ActiveRecordFlorder::Error, error_message
      end
    end

    # returns normalized position (positive rounded value)
    def normalize_position(position)
      round_value = min_position_delta.to_s.split('.').last.size
      if round_value > 0
        position.round(round_value)
      else
        (position / 10**(min_position_delta.to_s.size - 1)).round
      end
    end

    # Scope helper
    # returns value of scope attr
    def scope_value
      return unless position_scope_attr
      send(position_scope_attr)
    end
  end
end
