require 'active_support'

module ActiveModelFlorder
  # Doc will come here
  module DESC
    extend ActiveSupport::Concern

    included do
      include ActiveModelFlorder::Base

      scope :ordered, -> { order("#{position_attr_name} DESC") }
    end

    private

    def position_conflict_solver(conflicts, position)
      conflicts.each do |conflict|
        conflict_position = conflict.send(position_attr_name.to_sym)
        direction = conflict_position > position ? :increase : :decrease

        conflict.slide(direction)
      end
    end
  end
end
