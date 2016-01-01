class Owner < ActiveRecord::Base
  has_many :movables
end

class ASCMovable < ActiveRecord::Base
  self.table_name = 'movables'
  include ActiveModelFlorder::ASC

  belongs_to :owner
end

class DESCMovable < ActiveRecord::Base
  self.table_name = 'movables'
  include ActiveModelFlorder::DESC

  belongs_to :owner
end
