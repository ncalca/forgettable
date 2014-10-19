require 'spec_helper'

describe ForgetTable::Distribution do

  # Test with a real redis server
  let(:redis) { Redis.new(port: 10000) }
  let(:decrementer) { double(:decrementer) }
  let(:distribution) { ForgetTable::Distribution.new("guitars", redis) }

  before(:each) do
    redis.flushall
    allow(ForgetTable::Decrementer).to receive(:new).and_return(decrementer)
    allow(decrementer).to receive(:run!)
  end

  describe "#name" do
    it "reads the correct distribution_name" do
      expect(distribution.name).to eq("guitars")
    end
  end

  describe "#increment" do

    it "insert the value if it was not existing before" do
      distribution.increment("fender", 10)

      expect(distribution.distribution).to eq(["fender"])
    end

    it "sets the initial value if the item was not there before" do
      distribution.increment("fender", 10)

      expect(distribution.score_for_bin("fender")).to eq(10)
    end

    it "increments the existing value" do
      distribution.increment("fender", 10)
      distribution.increment("fender", 1)

      expect(distribution.score_for_bin("fender")).to eq(11)
    end
  end

  describe "#distribution" do
    before do
      distribution.increment("epiphone", 10)
      distribution.increment("gibson", 20)
      distribution.increment("fender", 30)
    end

    it "returns the list of all stored items" do
      expect(distribution.distribution).to match_array(["epiphone", "gibson", "fender"])
    end

    it "returns the list of the top n stored item" do
      expect(distribution.distribution(2)).to match_array(["gibson", "fender"])
    end

    it "returns at most the stored elements even if asked for more" do
      expect(distribution.distribution(42)).to match_array(["epiphone", "gibson", "fender"])
    end

    it "accepts a with_scores parameter" do
      expect(distribution.distribution(3, with_scores: true)).to match_array([["epiphone", 10.0], ["gibson", 20.0], ["fender", 30.0]])
    end

    it "returns and empty hash if the distribution is not stored in redis" do
      distribution = ForgetTable::Distribution.new("foo", redis)

      expect(distribution.distribution).to eq([[]])
    end
  end

  describe "#score_for_bin" do
    it "returns the score for a given stored item" do
      distribution.increment("ibanez", 37)

      expect(distribution.score_for_bin("ibanez")).to eq(37)
    end

    it "raises an exception if the distribution is not stored in redis" do
      distribution = ForgetTable::Distribution.new("foo", redis)

      expect{ distribution.score_for_bin("yolo") }.to raise_error
    end
  end
end
