require 'rspec'
require 'active_record'
require 'active_model_florder'

# TODO: load from config
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'active-model-florder_test'
)


RSpec.describe ActiveModelFlorder::Base do
  class Owner < ActiveRecord::Base
    has_many :movables
  end

  class Movable < ActiveRecord::Base
    include ActiveModelFlorder::Base

    belongs_to :owner
  end

  let(:owner_1) { Owner.create }
  let(:subject_1) { Movable.create(owner: owner_1)}
  let(:subject_2) { Movable.create(owner: owner_2)}

  it 'Database should be setup properly' do
    expect(subject_1.position).to_not eq(0)
  end
end
