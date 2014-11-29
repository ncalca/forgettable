require 'spec_helper'
require 'fakeredis'

describe "One bin distribution" do

  let(:redis) { Redis.new(port: 10000) }
  let(:distribution) { ForgetTable::Distribution.new(name: "guitars", redis: redis) }

  before do
    redis.flushall
  end

  describe "single bin" do
    context "with a single increment" do
      before do
        distribution.increment(bin: "fender", amount: 10)
      end

      it "returns the only bin" do
        expect(distribution.distribution).to eq(["fender"])
      end

      it "returns a positive score for the bin" do
        expect(distribution.score_for_bin("fender")).to be > 0
      end

      it "returns a positive number of hits" do
        expect(distribution.hits_count).to be > 0
      end
    end

    context "with multiple increment" do
      before do
        distribution.increment(bin: "fender", amount: 10)
        distribution.increment(bin: "fender", amount: 20)
        distribution.increment(bin: "fender", amount: 30)
      end

      it "returns the only bin" do
        expect(distribution.distribution).to eq(["fender"])
      end

      it "returns a positive score for the bin" do
        expect(distribution.score_for_bin("fender")).to be > 0
      end

      it "returns a positive number of hits" do
        expect(distribution.hits_count).to be > 0
      end
    end
  end

  describe "multiple bins" do
    context "with single increment" do
      before do
        distribution.increment(bin: "fender", amount: 10)
        distribution.increment(bin: "gibson", amount: 20)
      end

      it "returns both bins" do
        expect(distribution.distribution).to match_array(["fender", "gibson"])
      end

      it "returns a positive score for the bins" do
        expect(distribution.score_for_bin("fender")).to be > 0
        expect(distribution.score_for_bin("gibson")).to be > 0
      end

      it "respects the scoring order" do
        fender_score = distribution.score_for_bin("fender")
        gibson_score = distribution.score_for_bin("gibson")

        expect(gibson_score).to be >= fender_score
      end

      it "returns a positive number of hits" do
        expect(distribution.hits_count).to be > 0
      end
    end
  end
end
