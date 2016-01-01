module ActiveModelFlorder
  module ASC
    extend ActiveSupport::Concern

    POSITION_ATTR_NAME = :position

    included do
      include ActiveModelFlorder::Base

      # Models are sorted in DESCending order!
      scope :ordered, -> { order("#{POSITION_ATTR_NAME.to_s} ASC") }
    end

    private

    def position_conflict_solver(conflicts, position)
      conflicts.each do |conflict|
        conflict.slide(conflict[POSITION_ATTR_NAME.to_sym] >= position ? :increase : :decrease)
      end
    end
  end
end
