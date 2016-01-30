class Owner < ActiveRecord::Base
  has_many :configured_movables
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

  florder :desc, attribute: :position_2, scope: :owner, min_delta: 1, step: 10, return_all_affected: true
end
