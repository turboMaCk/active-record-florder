require 'active_support'

module ActiveModelFlorder
  # Doc will come here
  module ASC
    extend ActiveSupport::Concern

    included do
      include ActiveModelFlorder::Base

      scope :ordered, -> { order("#{position_attr_name} ASC") }
    end

    private

    def get_conflict_direction(position, conflict_position)
      conflict_position >= position ? :increase : :decrease
    end
  end
end
