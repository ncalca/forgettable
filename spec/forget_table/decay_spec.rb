require 'spec_helper'

describe ForgetTable::Decay do

  class FakePoisson
    attr_reader :sample
    def initialize(sample)
      @sample = sample
    end
  end

  let(:last_updated) { 100 }

  before do
    allow(ForgetTable::Poisson).to receive(:new) { |arg| FakePoisson.new(arg) }
  end

  describe "#decayed_values" do
    it "returns new values decayed" do
      allow(Time).to receive_message_chain(:now, :to_i).and_return(110)

      decay = ForgetTable::Decay.new([10, 20, 30], last_updated)


      expect(decay.decayed_values).to eq([8, 16, 24])
    end

    it "replaces negative decayed values with 1" do
      allow(Time).to receive_message_chain(:now, :to_i).and_return(500)

      decay = ForgetTable::Decay.new([20], last_updated)


      expect(decay.decayed_values).to eq([1])
    end
  end
end
