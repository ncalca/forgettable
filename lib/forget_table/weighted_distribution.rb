module ForgetTable

  class WeightedDistribution
    attr_reader :name, :bins

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

  end
end
