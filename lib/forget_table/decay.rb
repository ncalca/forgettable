module ForgetTable

  # Accepts an array of values, a timestamp and a rate (optional)
  # and produces a decayed version of the array values.
  class Decay

    DEFAULT_DECAY_RATE = 0.02

    # - values:       an array of values to be decayed
    # - last_updated: the timestamp of the last update
    # - rate:         the rate of the decay (optional)
    def initialize(values, last_updated, rate = DEFAULT_DECAY_RATE)
      @values = values
      @last_updated = last_updated
      @rate = rate
    end

    def decayed_values
      @decayed_values ||= compute_decay_values
    end

    private

    attr_reader :values, :last_updated, :rate

    def compute_decay_values
      values.map { |value| decay(value) }
    end

    def decay(value)
      decay = decay_constant * value
      decayed_value = value - poisson(decay)
      decayed_value > 0 ? decayed_value : 1
    end

    def decay_constant
      @decay_constant ||= rate * tau
    end

    def tau
      @tau ||= timestamp - last_updated
    end

    def poisson(value)
      Poisson.new(value).sample
    end

    def timestamp
      @timestamp ||= Time.now.to_i
    end
  end
end
