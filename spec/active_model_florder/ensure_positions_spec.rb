require 'spec_helper'

RSpec.describe ActiveRecordFlorder do
  context 'asc' do
    def fetch_ordered
      ASCMovable.ordered
    end

    describe 'generate position if it not set' do
      def create_model_without_position
        model = ASCMovable.create
        model.update_attribute(:position, nil)
      end

      before do
        10.times do
          create_model_without_position
        end

        ASCMovable.reinit_positions
      end

      it 'every model should have positions' do
        fetch_ordered.each do |model|
          expect(model.position).to_not be_nil
        end
      end

      it 'positions delta between models should equal step settings' do
        models = fetch_ordered
        models.each_with_index do |model, index|
          if index > 0
            expect(model.position - models[index-1].position).to eq(model.next_position_step)
          end
        end
      end
    end

    describe 'some have position' do
      def create_model_pair
        model = ASCMovable.create
        model.update_attribute(:position, nil)
        ASCMovable.create
      end

      before do
        5.times do
          create_model_pair
        end
      end

      it 'should not affect order' do
        results_before = fetch_ordered
        ASCMovable.reinit_positions

        expect(fetch_ordered).to eq(results_before)
      end
    end
  end

  context 'desc' do
    def fetch_ordered
      DESCMovable.ordered
    end

    describe 'generate position if it not set' do
      def create_model_without_position
        model = DESCMovable.create
        model.update_attribute(:position, nil)
      end

      before do
        10.times do
          create_model_without_position
        end

        DESCMovable.reinit_positions
      end

      it 'every model should have positions' do
        fetch_ordered.each do |model|
          expect(model.position).to_not be_nil
        end
      end

      it 'positions delta between models should equal step settings' do
        models = fetch_ordered
        models.each_with_index do |model, index|
          if index > 0
            expect(models[index-1].position - model.position).to eq(model.next_position_step)
          end
        end
      end
    end

    describe 'some have position' do
      def create_model_pair
        model = DESCMovable.create
        model.update_attribute(:position, nil)
        DESCMovable.create
      end

      before do
        5.times do
          create_model_pair
        end
      end

      it 'should not affect order' do
        results_before = fetch_ordered
        DESCMovable.reinit_positions

        expect(fetch_ordered).to eq(results_before)
      end
    end
  end
end
