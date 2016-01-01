RSpec.shared_examples 'errors' do
  let(:subject) { create_subject.call }

  describe "errors raising" do
    context "when position param is missing" do
      it { expect{ subject.move(nil) }.to raise_error(ActiveModelFlorder::Error) }
    end

    context "when position param <= 0" do
      it { expect{ subject.move(-1) }.to raise_error(ActiveModelFlorder::Error) }
      it { expect{ subject.move(0) }.to raise_error(ActiveModelFlorder::Error) }
    end
  end
end
