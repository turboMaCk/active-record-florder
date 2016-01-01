require 'spec_helper'

RSpec.describe ActiveModelFlorder::Error do
  let(:subject_1) { ASCMovable.create }

  describe "errors raising" do
    context "when position param is missing" do
      it { expect{ subject_1.move(nil) }.to raise_error(ActiveModelFlorder::Error) }
    end

    context "when position param <= 0" do
      it { expect{ subject_1.move(-1) }.to raise_error(ActiveModelFlorder::Error) }
      it { expect{ subject_1.move(0) }.to raise_error(ActiveModelFlorder::Error) }
    end
  end
end
