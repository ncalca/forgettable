require 'spec_helper'

describe ForgetTable::Decay do

  class FakePoisson
    attr_reader :sample
    def initialize(sample)
      @sample = sample
    end
  end

  let(:last_updated) { 1_000 }

  before do
    allow(ForgetTable::Poisson).to receive(:new) { |arg| FakePoisson.new(arg) }
  end

  describe "#decay" do
    let(:decay) { ForgetTable::Decay.new(last_updated, 0.01) }

    it "returns new decayed value" do
      set_current_time(1_010)

      expect(decay.decay_value(10)).to eq(9)
    end

    it "replaces negative decayed values with 1" do
      set_current_time(10_000)

      expect(decay.decay_value(20)).to eq(1)
    end

    def set_current_time(current_time)
      allow(Time).to receive_message_chain(:now, :to_i).and_return(current_time)
    end
  end
end
