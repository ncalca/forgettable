require 'spec_helper'

describe ForgetTable::Decrementer do

  let(:redis) { Redis.new(port: 10000) }
  let(:distribution_name) { "guitars" }
  let(:hits_count_key) { "guitars_z" }
  let(:last_updated_at_key) { "guitars_t" }

  let(:weighted_distribution) do
    double(:weighted_distribution, name: distribution_name)
  end

  let(:distribution_decrementer) do
    double(:distribution_decrementer, decrement: decremented_distribution)
  end

  let(:decremented_distribution) do
    double(:decremented_distribution,
           name: distribution_name,
           bins: { "fender" => 10.0, "gibson" => 20.0 },
           hits_count: 30.0,
          )
  end

  let(:decrementer) do
    ForgetTable::Decrementer.new(
      redis,
      weighted_distribution
    )
  end

  before(:each) do
    redis.flushall
    redis.set("guitars_t", 123)

    allow(ForgetTable::DistributionDecrementer).to receive(:new).
      with(
        weighted_distribution: weighted_distribution,
        last_updated_at: 123
    ) { distribution_decrementer }
  end

  describe "#run!" do
    it "updates the `hits_count` key after decrementing" do
      decrementer.run!

      expect(redis.get(hits_count_key).to_i).to eq(30)
    end

    it "updates the timestamp" do
      allow(Time).to receive_message_chain(:now, :to_i) { 37 }

      decrementer.run!

      expect(redis.get(last_updated_at_key).to_i).to eq(37)
    end

    it "stores the new values for the distribution" do
      decrementer.run!

      distribution = redis.zrevrange(distribution_name, 0, -1, with_scores: true)
      expect(distribution).to match_array(
        [
          ["fender", 10.0],
          ["gibson", 20.0],
        ])
    end
  end
end
