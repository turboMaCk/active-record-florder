require 'active_support'

module ActiveModelFlorder
  # Doc will come here
  module Base
    extend ActiveSupport::Concern

    POSITION_ATTR_NAME = :position
    MIN_POSITION_DELTA = 0.0005
    POSITION_SCOPE_ATTR = :owner_id
    NEXT_POSITION_STEP = 2**16
    included do
      before_create -> { push(:highest) }

      # scoped ordered items by POSITION_SCOPE_ATTR eg. user_id, folder_id ...
      scope :position_scope, lambda { |value|
        return default_scoped if POSITION_SCOPE_ATTR.empty?
        where(POSITION_SCOPE_ATTR.to_sym => value)
      }
    end

    def move(position)
      position.to_f

      fail ActiveModelFlorder::Error, "Position param is required" unless position
      fail ActiveModelFlorder::Error, "Position should be > 0" unless (normalized_position = normalize_position(position)) > 0
      ensure_position_solving(position, normalized_position)

      if new_record?
        self[POSITION_ATTR_NAME.to_sym] = normalized_position
      else
        update_attribute(POSITION_ATTR_NAME.to_sym, normalized_position)
      end

      self
    end

    protected

    def slide(direction)
      sibling_position = get_sibling(direction).try(POSITION_ATTR_NAME.to_sym)

      if sibling_position
        move((self[POSITION_ATTR_NAME.to_sym] + sibling_position) / 2.0)
      else
        push(direction == :increase ? :highest : :lowest)
      end
    end

    private

    def push(place)
      return move(NEXT_POSITION_STEP) unless self.class.position_scope(scope_value).any?

      sibling_position = get_sibling(place).try(POSITION_ATTR_NAME.to_sym)

      position = calc_push_position(place, sibling_position)
      move(position)
    end

    def calc_push_position(place, sibling_position)
      case place
      when :highest
        sibling_position + NEXT_POSITION_STEP
      when :lowest
        sibling_position / 2.0
      end
    end

    # Find all models with conflicting position and solve conflicts
    def ensure_position_solving(position, normalized_position)
      min = normalized_position - MIN_POSITION_DELTA
      max = normalized_position + MIN_POSITION_DELTA

      conflicts = self.class.position_scope(scope_value)
                  .where("#{POSITION_ATTR_NAME} > ? AND #{POSITION_ATTR_NAME} < ?", min, max)
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
        [["#{POSITION_ATTR_NAME} > ?",
          self[POSITION_ATTR_NAME.to_sym]],
         "#{POSITION_ATTR_NAME} DESC"]
      when :decrease
        [["#{POSITION_ATTR_NAME} < ?",
          self[POSITION_ATTR_NAME.to_sym]],
         "#{POSITION_ATTR_NAME} ASC"]
      when :highest
        [nil,
         "#{POSITION_ATTR_NAME} DESC"]
      when :lowest
        [nil,
         "#{POSITION_ATTR_NAME} ASC"]
      else
        error_message = "Place param '#{place}' is not one of: increase, decrease, highest, lowest."
        fail ActiveModelFlorder::Error, error_message
      end
    end

    # returns normalized position (positive rounded value)
    def normalize_position(position)
      position.round(MIN_POSITION_DELTA.to_s.split('.').last.size)
    end

    # Scope helper
    # returns value of scope attr
    def scope_value
      send(POSITION_SCOPE_ATTR)
    end
  end
end
