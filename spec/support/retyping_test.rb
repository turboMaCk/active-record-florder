RSpec.shared_examples "retype position" do
  let(:subject) { create_subject.call }

  it "retype position attr to float" do
      new_position = "14.6"
      subject.move(new_position)
      expect(subject.position).to eq(new_position.to_f)
  end
end
