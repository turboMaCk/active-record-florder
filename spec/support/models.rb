class Owner < ActiveRecord::Base
  has_many :movables
end

class ASCMovable < ActiveRecord::Base
  self.table_name = 'movables'
  belongs_to :owner

  florder :asc
end

class DESCMovable < ActiveRecord::Base
  self.table_name = 'movables'
  belongs_to :owner

  florder :desc
end

class ConfiguredMovable < ActiveRecord::Base
  self.table_name = 'movables'
  belongs_to :owner

  florder :desc, scope: :owner_id, min_delta: 1, step: 10
end
