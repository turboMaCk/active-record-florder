require 'active_support'

module ActiveModelFlorder
  module DESC
    extend ActiveSupport::Concern

    included do
      include ActiveModelFlorder::Base
    end
  end
end
