require 'spec_helper'

RSpec.describe ActiveRecordFlorder::Configurable do
  context 'model settings' do
    let(:owner) { Owner.create }

    def create_subject
        lambda {
          ConfiguredMovable.create(owner: owner)
        }
    end

    let!(:subject_1) { create_subject.call }
    let!(:subject_2) { create_subject.call }
    let!(:subject_3) { create_subject.call }
    let(:step_config) { subject_1.class::min_position_delta }

    def fetch_ordered
      owner.configured_movables.ordered
    end

    describe 'position attr name' do
      it 'should have 0 position attr' do
        expect(subject_1.position).to eq(0)
      end

      it 'should use position_2' do
        expect(subject_1.position_2).to_not eq(0)
      end
    end

    describe 'position scope attr' do
      before(:each) do
        subject_1.update(owner: Owner.create)
        subject_1.move(1)
        subject_2.move(1)
        subject_3.move(2)
      end

      it 'conflicts are solved in scope context' do
        expect(subject_1.position_2).to eq(subject_2.position_2)
        expect(subject_1.position_2).to eq(1)
      end

      it 'should return colections correctly' do
        expect(fetch_ordered).to eq [subject_3, subject_2]
      end
    end

    describe 'min position delata' do
      before(:each) do
        subject_1.move(1)
        subject_2.move(1)
        subject_3.move(1)
      end

      it 'should respect given value' do
        expect(step_config).to eq(1)
        puts subject_1.position_2 / 10**(step_config.to_s.size - 1).round
        puts subject_2.reload.position_2 - subject_1.reload.position_2
        expect(subject_3.reload.position_2 - subject_2.reload.position_2 > step_config).to be_truthy
        expect(subject_2.position_2 - subject_1.position_2 > step_config).to be_truthy
        expect(subject_3.position_2 - subject_1.position_2 > 2 * step_config).to be_truthy
      end
    end
  end
end
