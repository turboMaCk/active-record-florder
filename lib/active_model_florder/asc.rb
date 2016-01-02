require 'active_support'

module ActiveModelFlorder
  # Doc will come here
  module ASC
    extend ActiveSupport::Concern

    POSITION_ATTR_NAME = :position

    included do
      include ActiveModelFlorder::Base

      scope :ordered, -> { order("#{POSITION_ATTR_NAME} ASC") }
    end

    private

    def position_conflict_solver(conflicts, position)
      conflicts.each do |conflict|
        conflict_position = conflict[POSITION_ATTR_NAME.to_sym]
        direction = conflict_position >= position ? :increase : :decrease
        conflict.slide(direction)
      end
    end
  end
end
