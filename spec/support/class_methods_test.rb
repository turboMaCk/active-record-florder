RSpec.shared_examples 'class methods' do
  let(:subject_1) { create_subject.call }
  let(:step) { subject_1.next_position_step }

  def fetch_models
    subject_1.class.all.order('position ASC')
  end

  describe 'reinit positions' do
    before do
      10.times do
        model = create_subject.call
        model.move(Random.rand(11) + 1)
      end
    end

    it 'should not affect order' do
      results_before = fetch_ordered
      subject_1.class.reinit_positions

      expect(fetch_ordered).to eq(results_before)
    end

    it 'should generate new positions based on nex position step' do
      models = fetch_models

      models.each_with_index do |model, index|
        if index > 0
          expect(model.position - models[index-1].position = step).to be_truthy
        end
      end
    end
  end
end
