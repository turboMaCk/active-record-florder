require 'spec_helper'

RSpec.describe ActiveRecordFlorder::Base do
  let(:create_subject) {
        lambda {
          DESCMovable.create
        }
      }

  let!(:subject_1) { create_subject.call }
  let!(:subject_2) { create_subject.call }
  let!(:subject_3) { create_subject.call }
  let(:step_config) { subject_1.class::min_position_delta }

  def fetch_ordered
    subject_1.class.ordered
  end

  it 'Should be sorted in DESCending order' do
    subject_1.reload
    subject_2.reload
    subject_3.reload

    results = fetch_ordered
    expect(results.first.position > results.last.position).to be_truthy
  end

  context 'when create a new item' do
    let!(:subject_4) { create_subject.call }

    it 'should be positioned as first' do
      expect(fetch_ordered).to eq [subject_4, subject_3, subject_2, subject_1]
    end
  end

  describe 'position normalize' do
    it 'should use passed value if it is valid' do
      expect(subject_1.move(3).position).to eq(3)
    end

    it 'should round small values' do
      expect(subject_1.move(1.123333333333).position).to eq(1.1233)
    end
  end

  describe 'solving position delta conflicts' do
    context 'moving items on same position' do
      before do
        subject_1.move(1)
        subject_2.move(1)
        subject_3.move(1)
      end

      it 'should resolve equals conflict and show new before' do
        expect(fetch_ordered).to eq [subject_3, subject_2, subject_1]
      end
    end

    context 'move items in range less then MIN_POSITION_DELTA' do
      before do
        subject_1.move(1)
        subject_2.move(1 - step_config)
        subject_3.move(1 - step_config/2)
      end

      it 'return correct order' do
        expect(fetch_ordered).to eq [subject_1, subject_3, subject_2]
      end

      it 'correct positions to not be in MIN_POSITION_DELTA range' do
        expect(fetch_ordered.first.position - fetch_ordered.last.position < step_config*2).to be_falsy
      end
    end
  end

  describe 'scoping' do
    context 'by default scope is not used' do
      before do
        subject_1.update(owner: Owner.create)
        subject_3.move(0.9)
        subject_1.move(1)
        subject_2.move(1)
      end

      it 'should return all' do
        expect(fetch_ordered).to eq [subject_2, subject_1, subject_3]
        expect(subject_1.position).to eq(1)
        expect(subject_2.position).to eq(1)
      end
    end
  end

  describe 'min position delta should be respected' do
    before(:each) do
      subject_1.move(1)
      subject_2.move(1 - step_config)
      subject_3.move(1)
    end

    it 'should generate delata < than settup value' do
      expect((fetch_ordered.first.position - fetch_ordered[1].position).abs.round(4) >= step_config).to be_truthy
      expect((fetch_ordered[1].position - fetch_ordered.last.position).abs.round(4) >= step_config).to be_truthy
      expect((fetch_ordered.first.position - fetch_ordered.last.position).abs.round(4) >= step_config*2).to be_truthy
    end

    it 'should not affect order' do
      expect(fetch_ordered).to eq [subject_3, subject_1, subject_2]
    end
  end

  include_examples 'errors'
  include_examples 'base'
  include_examples 'class methods'
end
