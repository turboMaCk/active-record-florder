require 'active_support'

module ActiveModelFlorder
  module Base
    extend ActiveSupport::Concern

    MIN_POSITION_DELTA = 0.0005
    POSITION_SCOPE_ATTR = :owner_id
    NEXT_POSITION_STEP = 2**16
    POSITION_ATTR_NAME = :position

    included do
      before_create do
        push(:first)
      end

      # Models are sorted in DESCending order!
      scope :ordered, -> { order("#{POSITION_ATTR_NAME.to_s} DESC") }

      # scoped ordered items by POSITION_SCOPE_ATTR eg. user_id, folder_id ...
      scope :position_scope, -> (value) {
        return default_scoped if POSITION_SCOPE_ATTR.empty?
        where(POSITION_SCOPE_ATTR.to_sym => value)
      }
    end

    def move(position)
      position.to_f

      fail ActiveModelFlorder::Error, "Position param is required" unless position
      fail ActiveModelFlorder::Error, "Position should be > 0" unless (normalized_position = normalize_position(position)) > 0
      position_conflict_solver(position, normalized_position)

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
        move((position + sibling_position) / 2.0)
      else
        push(direction == :up ? :first : :last)
      end
    end

    private

    def push(place)
      return move(NEXT_POSITION_STEP) unless self.class.position_scope(scope_value).any?

      sibling_position = get_sibling(place).try(POSITION_ATTR_NAME.to_sym)

      position = case place
      when :first
        sibling_position + NEXT_POSITION_STEP # related sibling is first (highest position + STEP const => new pos
      when :last
        sibling_position / 2.0 # related sibling is last (lowest position and then is 0 -> lowest / 2 => new pos
      end

      move(position)
    end

    # Find all models with conflicting position and solve conflicts
    def position_conflict_solver(position, normalized_position)
      min = normalized_position - MIN_POSITION_DELTA
      max = normalized_position + MIN_POSITION_DELTA

      conflicts = self.class.position_scope(scope_value).where("#{POSITION_ATTR_NAME.to_s} > ? AND #{POSITION_ATTR_NAME.to_s} < ?", min, max).where.not(id: id).order(:position)

      conflicts.each do |conflict|
        conflict.slide(conflict[POSITION_ATTR_NAME.to_sym] > position ? :up : :down)
      end
    end

    def get_sibling(place)
      conditions = case place
        when :up
          [["#{POSITION_ATTR_NAME.to_s} > ?", self[POSITION_ATTR_NAME.to_sym]], "#{POSITION_ATTR_NAME.to_s} DESC"]
        when :down
          [["#{POSITION_ATTR_NAME.to_s} < ?", self[POSITION_ATTR_NAME.to_sym]], "#{POSITION_ATTR_NAME.to_s} ASC"]
        when :first
          [nil, "#{POSITION_ATTR_NAME.to_s} DESC"]
        when :last
          [nil, "#{POSITION_ATTR_NAME.to_s} ASC"]
        else
          fail OrderableError, "Place param '#{place}' is not one of: up, down, first, last."
        end

      self.class.position_scope(scope_value).where(conditions.first).order(conditions.last).limit(1).first
    end

    # returns normalized position (positive rounded value)
    def normalize_position(position)
      position.round(MIN_POSITION_DELTA.to_s.split('.').last.size)
    end

    # Scope helper
    # returns value of scope attr
    def scope_value
      self.send(POSITION_SCOPE_ATTR)
    end
  end
end
