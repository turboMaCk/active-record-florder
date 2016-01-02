RSpec.shared_examples 'base' do
  let(:subject_1) { create_subject.call }
  let(:subject_2) { create_subject.call }
  let(:subject_3) { create_subject.call }

  def fetch_asc
    subject_1.class.all.order('position ASC')
  end

  describe "protected methods" do
    it "lowest position" do
      subject_1.move(1)
      subject_2.move(2)
      subject_3.move(3)
      subject_3.send(:push, :lowest)

      expect(fetch_asc).to eq [subject_3, subject_1, subject_2]
    end

    it "highest position" do
      subject_1.move(1)
      subject_2.move(2)
      subject_3.move(3)
      subject_3.send(:push, :highest)

      expect(fetch_asc).to eq [subject_1, subject_2, subject_3]
    end

    describe "#highest" do
      it "increase should not affect order" do
        subject_1.move(1)
        subject_2.move(2)
        subject_3.move(3)
        subject_2.send(:slide, :increase)

        expect(fetch_asc).to eq [subject_1, subject_2, subject_3]
        expect(subject_2.position > 2).to be_truthy
      end

      it "increase should not affect order" do
        subject_1.move(1)
        subject_2.move(2)
        subject_3.move(3)
        subject_2.send(:slide, :decrease)

        expect(fetch_asc).to eq [subject_1, subject_2, subject_3]
        expect(subject_2.position < 2).to be_truthy
      end
    end
  end
end
