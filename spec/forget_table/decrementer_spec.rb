require 'spec_helper'

describe ForgetTable::Decrementer do

  let(:redis) { Redis.new(port: 10000) }
  let(:distribution_name) { "guitars" }

  let(:last_updated_key) { "guitars_t" }
  let(:hits_count_key) { "guitars_z" }

  let(:decrementer) do
    ForgetTable::Decrementer.new(
      redis,
      distribution_name,
      last_updated_key,
      hits_count_key
    )
  end

  class FakeDecay
    attr_reader :decayed_values
    def initialize(args)
      @decayed_values = args.map { |v| v - 1 }
    end
  end

  before(:each) do
    allow(ForgetTable::Decay).to receive(:new) { |arg| FakeDecay.new(arg) }
    redis.flushall
  end

  describe "#run" do
    it "raises an exception if not distribution is associated with this key" do
      expect { decrementer.run }.to raise_error
    end

    context "with data" do
      before do
        redis.zincrby(distribution_name, 10, "fender")
        redis.zincrby(distribution_name, 5, "gibson")
        redis.set(hits_count_key, 15)
        redis.set(last_updated_key, 123)
      end

      it "updates the `hits_count` key after decrementing" do
        decrementer.run

        expect(redis.get(hits_count_key).to_i).to eq(13)
      end

      it "updates the timestamp" do
        allow(Time).to receive_message_chain(:now, :to_i) { 37 }

        decrementer.run

        expect(redis.get(last_updated_key).to_i).to eq(37)
      end

      it "stores the new values for the distribution" do
        decrementer.run

        expect(redis.zrevrange(distribution_name, 0, -1, with_scores: true)).to eq(
          [
            ["fender", 9.0],
            ["gibson", 4.0],
        ])
      end
    end
  end
end
