module ActiveRecordFlorder

  # Mixin for extending ActiveRecord::Base
  # These methods are available in Models
  module Models

    # Initialize ActiveRecordFlorder with given options
    # @param type [:asc, :desc], required!
    # @param opts {Hash}, optional
    def florder(type, opts = {})

      # require type
      fail ActiveRecordFlorder::Error, 'Define florder type :asc/:desc' unless [:asc, :desc].include?(type)

      # setup configuration var
      @florder_config = {}
      @florder_config[:type] = type.to_sym

      # add opts to config
      opts.each do |key, value|
        @florder_config[key.to_sym] = value
      end

      # include florder mixin
      include ActiveRecordFlorder::Base
    end
  end
end
