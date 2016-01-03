module ActiveRecordFlorder
  module Models
    def florder(type, opts = {})
      fail ActiveRecordFlorder::Error, 'Define florder type :asc/:desc' unless [:asc, :desc].include?(type)
      @florder_config = {}
      @florder_config[:type] = type.to_sym

      opts.each do |key, value|
        @florder_config[key.to_sym] = value
      end

      include ActiveRecordFlorder::Base
    end
  end
end
