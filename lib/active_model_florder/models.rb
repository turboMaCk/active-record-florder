module ActiveModelFlorder
  module Models
    def florder(type, opts={})
      fail ActiveModelFlorder::Error, 'Define florder type :asc/:desc' unless [:asc, :desc].include?(type)
      @florder_config = {}
      @florder_config[:type] = type.to_sym

      opts.each do |key, value|
        @florder_config[key.to_sym] = value
      end

      include ActiveModelFlorder::Base
    end
  end
end
