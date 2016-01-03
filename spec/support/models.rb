class Owner < ActiveRecord::Base
  has_many :movables
end

class ASCMovable < ActiveRecord::Base
  self.table_name = 'movables'
  florder :asc

  belongs_to :owner
end

class DESCMovable < ActiveRecord::Base
  self.table_name = 'movables'
  florder :desc

  belongs_to :owner
end
