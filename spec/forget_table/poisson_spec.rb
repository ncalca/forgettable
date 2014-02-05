require 'spec_helper'

describe ForgetTable::Poisson do

  context ".sample" do

    REPETITIONS = 1000

    it "raises an exception if average is negative" do
      expect { ForgetTable::Poisson.new(-1) }.to raise_error(ArgumentError)
    end

    it "should always generate an integer" do
      REPETITIONS.times do
        expect(ForgetTable::Poisson.new(37).sample).to be_kind_of(Integer)
      end
    end

    it "should always be within the acceptance range" do
      sum = 0
      REPETITIONS.times do
        sum += ForgetTable::Poisson.new(37).sample
      end
      sum /= REPETITIONS.to_f

      expect(sum).to be_within(1).of(37)
    end
  end
end
