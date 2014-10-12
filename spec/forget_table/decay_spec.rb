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

  describe "#decay" do
    let(:decay) { ForgetTable::Decay.new(last_updated) }

    it "returns new decayed value" do
      allow(Time).to receive_message_chain(:now, :to_i).and_return(110)

      expect(decay.decay(10)).to eq(8)
    end

    it "replaces negative decayed values with 1" do
      allow(Time).to receive_message_chain(:now, :to_i).and_return(500)

      expect(decay.decay(20)).to eq(1)
    end
  end
end
