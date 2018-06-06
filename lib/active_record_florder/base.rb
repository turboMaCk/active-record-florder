require 'active_support'

module ActiveRecordFlorder

  # Base model implements all required logic
  # It's depend on ActiveRecordFlorder::Configurable attributes
  module Base
    extend ActiveSupport::Concern

    included do

      # Include configuration methods
      extend ActiveRecordFlorder::Configurable::ClassMethods
      include ActiveRecordFlorder::Configurable

      # Set initial position new records
      before_create -> { push(:highest) }

      # Scope all positions solving
      # @api public
      scope :position_scope, lambda { |value|
        return all unless position_scope_attr.present? && value.present?
        where(position_scope_attr.to_sym => value)
      }

      # Public Class method for getting models in right order
      # @api public
      scope :ordered, lambda {
        direction = florder_direction.to_sym == :desc ? 'DESC' : 'ASC'
        order("#{quoted_table_name}.#{position_attr_name} #{direction}")
      }

      # Generates optimal positions, do not affect order
      # @api public
      def self.reinit_positions
        all.order("#{quoted_table_name}.#{position_attr_name} ASC").each_with_index do |model, index|
          model.update_attribute(position_attr_name.to_sym, (index + 1) * next_position_step)
        end
      end
    end

    # Move model to position
    # @param position {Float}
    # @returns self {ModelInstance}
    # @api public
    def move(position)
      position = position.to_f

      fail ActiveRecordFlorder::Error, 'Position param is required' unless position
      fail ActiveRecordFlorder::Error, 'Position should be > 0' unless (normalized_position = normalize_position(position)) > 0
      normalized_position = normalize_position(position)

      affected = ensure_position_solving(position, normalized_position)

      if new_record?
        self[position_attr_name.to_sym] = normalized_position
      else
        update_attribute(position_attr_name.to_sym, normalized_position)
      end

      # populating all affected records
      # only if return_all_affected_by_move option is true
      if return_all_affected_by_move
        affected ||= []
        return affected << self
      end

      self
    end

    protected

    # Increase/decrease models position but do not affect order
    # @param direction [:increase, :decrease]
    def slide(direction, ensured_position)
      sibling = get_sibling(direction)

      if sibling
        slide_to_sibling(direction, sibling, ensured_position)
      else
        push(direction == :increase ? :highest : :lowest)
      end
    end

    private

    # Increase/decrease models position for cases where it should respect siblings
    # @param direction [:increase, :desrease]
    # @param sibling {Object}
    # @param ensured_position {Float}
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

      quoted_table_name = self.class.quoted_table_name

      self.class.position_scope(scope_value)
        .where("#{quoted_table_name}.#{position_attr_name} > ? AND #{quoted_table_name}.#{position_attr_name} < ?", max, min).each do |conflict|
          c.slide(direction)
        end

      move(new_position)
    end

    # Helper for getting value to SELECTconflict in one direction
    # @param direction [:increase, :decrease]
    # @param ensured_position {Float}
    # @returns {Float}
    def get_slide_edge_position(direction, ensured_position)
      direction == :increase ? ensured_position + min_position_delta : ensured_position - min_position_delta
    end

    # Send model to end or begening
    # @param place [:highest, :lowest]
    def push(place)
      unless self.class.position_scope(scope_value).any? { |m| m.position.present? }
        return move(next_position_step)
      end

      sibling_position = get_sibling(place).try(position_attr_name.to_sym)

      position = calc_push_position(place, sibling_position)

      move(position)
    end

    # Calculate Edge (highest or lowest) positions based on current position of edge record
    # @param place [:highest, :lowest]
    # @param sibling_position {Float}
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
    # @param position {Float}
    # @param normalized_position {Float}
    def ensure_position_solving(position, normalized_position)
      min = normalized_position - min_position_delta
      max = normalized_position + min_position_delta

      quoted_table_name = self.class.quoted_table_name

      conflicts = self.class.position_scope(scope_value)
                  .where("#{quoted_table_name}.#{position_attr_name} > ? AND #{quoted_table_name}.#{position_attr_name} < ?", min, max)
                  .where.not(id: id)
                  .order(:position)

      position_conflict_solver(conflicts, position, normalized_position) if conflicts.present?
    end

    # Resolve all given conflicts
    # @param conflicts {Array}
    # @param position {Float}
    # @param normalized_position {Float}
    def position_conflict_solver(conflicts, position, normalized_position)
      conflicts.each do |conflict|
        conflict_position = conflict.send(position_attr_name.to_sym)
        direction = get_conflict_direction(position, conflict_position)
        conflict.slide(direction, normalized_position)
      end
    end

    # Helper condition for deciding conflict solving direction
    # @param position {Float}
    # @param conflict_position {Float}
    # @returns Symbol [:increase, :decrease]
    def get_conflict_direction(position, conflict_position)
      conflict_position > position ? :increase : :decrease
    end

    # Sibblings getter for given vector
    # @place [:increase, :decrease, :highest, :lowest]
    # @returns Object
    def get_sibling(vector)
      conditions = get_siblings_conditions(vector)

      self.class.position_scope(scope_value)
        .where(conditions.first)
        .order(conditions.last)
        .limit(1).first
    end

    # get paramets for sibling SELECT
    # @param vector [:increase, :decrease, :highest, :lowest]
    # @returns Array
    def get_siblings_conditions(vector)
      quoted_table_name = self.class.quoted_table_name

      case vector
      when :increase
        [["#{quoted_table_name}.#{position_attr_name} > ?",
          send(position_attr_name.to_sym)],
         "#{quoted_table_name}.#{position_attr_name} DESC"]
      when :decrease
        [["#{quoted_table_name}.#{position_attr_name} < ?",
          send(position_attr_name.to_sym)],
         "#{quoted_table_name}.#{position_attr_name} ASC"]
      when :highest
        [nil,
         "#{quoted_table_name}.#{position_attr_name} DESC"]
      when :lowest
        [nil,
         "#{quoted_table_name}.#{position_attr_name} ASC"]
      else
        error_message = "Place param '#{place}' is not one of: increase, decrease, highest, lowest."
        fail ActiveRecordFlorder::Error, error_message
      end
    end

    # returns normalized position (roundend value)
    # @param position {Float}
    # @returns Float
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
