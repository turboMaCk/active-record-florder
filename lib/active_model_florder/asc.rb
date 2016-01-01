require 'active_support'

module ActiveModelFlorder
  module ASC
    extend ActiveSupport::Concern

    included do
      include ActiveModelFlorder::Base
    end
  end
end
