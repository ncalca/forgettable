module ForgetTable

  class WeightedDistribution
    attr_reader :name

    def initialize(name:, bins:)
      @name = name
      @bins = bins
    end

    def values
      bins.values
    end

    def bin_names
      bins.keys
    end

    def hits_count
      values.inject(:+)
    end

    private

    attr_reader :bins
  end
end
