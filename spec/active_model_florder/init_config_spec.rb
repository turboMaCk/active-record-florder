require 'spec_helper'

RSpec.describe ActiveRecordFlorder do
  before(:all) do
    ActiveRecordFlorder.configure do |config|
      config.scope = :owner
      config.attribute = :position_2
      config.step = 3
      config.min_delta = 0.1
      config.return_all_affected = true
    end
  end

  let(:subject) { ASCMovable.create }

  it 'should be configured' do
    expect(subject.position_attr_name).to eq(:position_2)
    expect(subject.position_scope_attr).to eq(:owner)
    expect(subject.next_position_step).to eq(3)
    expect(subject.min_position_delta).to eq(0.1)
    expect(subject.return_all_affected_by_move).to eq(true)
  end
end
