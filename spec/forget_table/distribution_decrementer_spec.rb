require 'spec_helper'
require 'forget_table/distribution_decrementer'

describe ForgetTable::DistributionDecrementer do

  let(:last_updated_at) { "updated_at" }
  let(:weighted_distribution) do
    double(:dist,
           name: "foo",
           values: [13, 17],
           bin_names: %w(fender gibson)
          )
  end

  let(:dist_decrementer) do
    ForgetTable::DistributionDecrementer.new(
      weighted_distribution: weighted_distribution,
      last_updated_at: last_updated_at
    )
  end

  before do
    allow(ForgetTable::Decay).to receive(:new).with(
      last_updated_at, ForgetTable::Configuration.decay_rate
    ) { |arg| FakeDecay.new(arg) }
  end

  class FakeDecay
    def initialize(*); end

    # Just decrement by 1
    def decay_value(value)
      value - 1
    end
  end

  describe "#decremented_distribution" do
    it "returns a new distribution with the same name" do
      expect(dist_decrementer.decremented_distribution.name).to eq("foo")
    end

    it "returns a new distribution with decremented bins" do
      decremented_distribution = double
      allow(ForgetTable::WeightedDistribution).to receive(:new).with(
        name: "foo",
        bins: { "fender" => 12, "gibson" => 16 }
      ).and_return(decremented_distribution)

      expect(dist_decrementer.decremented_distribution).to eq(decremented_distribution)
    end
  end
end
