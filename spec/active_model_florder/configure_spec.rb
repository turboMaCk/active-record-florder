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

    describe 'normalization' do
      it 'should round based on min delta settings' do
        subject_1.move(1.1)
        expect(subject_1.position_2).to eq(1)
      end
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

        expect(fetch_ordered.first.position_2 - fetch_ordered[1].position_2 >= step_config).to be_truthy
        expect(fetch_ordered[1].position_2 - fetch_ordered.last.position_2 >= step_config).to be_truthy
        expect(fetch_ordered.first.position_2 - fetch_ordered.last.position_2 >= 2 * step_config).to be_truthy
      end
    end

    describe 'next position step' do
      it 'should respect settings' do
        expect((subject_1.position_2 - subject_2.position_2).abs).to eq(subject_1.class.next_position_step)
      end
    end

    describe 'populate' do
      before(:each) do
        subject_1.move(1)
      end

      it 'should return all affected records' do
        expect(subject_2.move(1)).to eq([subject_1, subject_2])
      end
    end
  end
end
