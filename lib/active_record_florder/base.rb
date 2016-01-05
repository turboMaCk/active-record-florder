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

      def self.reinit_positions
        all.order("#{position_attr_name} ASC").each_with_index do |model, index|
          model.update_attribute(position_attr_name.to_sym, (index + 1) * next_position_step)
        end
      end
    end

    def move(position)
      position.to_f

      fail ActiveRecordFlorder::Error, 'Position param is required' unless position
      fail ActiveRecordFlorder::Error, 'Position should be > 0' unless (normalized_position = normalize_position(position)) > 0
      normalized_position = normalize_position(position)

      ensure_position_solving(position, normalized_position)

      if new_record?
        self[position_attr_name.to_sym] = normalized_position
      else
        update_attribute(position_attr_name.to_sym, normalized_position)
      end

      self
    end

    protected

    def slide(direction, ensured_position)
      sibling = get_sibling(direction)

      if sibling
        slide_to_sibling(direction, sibling, ensured_position)
      else
        push(direction == :increase ? :highest : :lowest)
      end
    end

    private

    def slide_to_sibling(direction, sibling, ensured_position)
      sibling_position = sibling.try(position_attr_name.to_sym)
      position = send(position_attr_name.to_sym)
      new_position = (position + sibling_position) / 2

      if (new_position - ensured_position).abs < min_position_delta
        new_position = get_slide_edge_position(direction, ensured_position)
      end

      unless (normalize_position(new_position) > 0)
        return self.class.reinit_positions
      end

      min = new_position - min_position_delta
      max = new_position + min_position_delta

      self.class.position_scope(scope_value)
        .where("#{position_attr_name} > ? AND #{position_attr_name} < ?", max, min).each do |conflict|
          c.slide(direction)
        end

      move(new_position)
    end

    def get_slide_edge_position(direction, ensured_position)
      direction == :increase ? ensured_position + min_position_delta : ensured_position - min_position_delta
    end

    def push(place)
      unless self.class.position_scope(scope_value).any? { |m| m.position.present? }
        return move(next_position_step)
      end

      sibling_position = get_sibling(place).try(position_attr_name.to_sym)

      position = calc_push_position(place, sibling_position)

      move(position)
    end

    def calc_push_position(place, sibling_position)
      return unless sibling_position

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

      position_conflict_solver(conflicts, position, normalized_position) if conflicts.present?
    end

    def position_conflict_solver(conflicts, position, normalized_position)
      conflicts.each do |conflict|
        conflict_position = conflict.send(position_attr_name.to_sym)
        direction = get_conflict_direction(position, conflict_position)
        conflict.slide(direction, normalized_position)
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
      splitted_value = min_position_delta.to_s.split('.')

      if splitted_value.size.to_i > 1
        position.round(splitted_value.last.size)
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
