require 'spec_helper'
require 'forget_table/weighted_distribution'

describe ForgetTable::WeightedDistribution do

  let(:distribution) do
    ForgetTable::WeightedDistribution.new(
      name: "foo",
      bins: { "fender" => 10, "gibson" => 20 }
    )
  end

  it "returns the distribution name" do
    expect(distribution.name).to eq("foo")
  end

  it "returns the array of values" do
    expect(distribution.values).to eq([10, 20])
  end

  it "returns the array of bin names" do
    expect(distribution.bin_names).to eq(["fender", "gibson"])
  end

  it "returns the total number of hits" do
    expect(distribution.hits_count).to eq(30)
  end
end
