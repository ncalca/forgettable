module ForgetTable

  class DistributionDecrementer

    def initialize(weighted_distribution:, last_updated_at:)
      @weighted_distribution = weighted_distribution
      @last_updated_at = last_updated_at
    end

    def decremented_distribution
      WeightedDistribution.new(
        name: weighted_distribution.name,
        bins: decremented_bins
      )
    end

    private

    attr_reader :weighted_distribution, :last_updated_at

    def decremented_bins
      decremented_values = decrement(weighted_distribution.values)
      bin_names = weighted_distribution.bin_names
      Hash[*bin_names.zip(decremented_values).flatten]
    end

    def decrement(values)
      decay = Decay.new(last_updated_at, decay_rate)
      values.map { |value| decay.decay_value(value) }
    end

    def decay_rate
      ForgetTable::Configuration.decay_rate
    end
  end
end
