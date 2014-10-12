module ForgetTable

  class Decay

    DEFAULT_DECAY_RATE = 0.02

    # - values:       an array of values to be decayed
    # - last_updated: the timestamp of the last update
    # - rate:         the rate of the decay (optional)
    def initialize(last_updated, rate = DEFAULT_DECAY_RATE)
      @last_updated = last_updated
      @rate = rate
    end

    def decay(value)
      decay = decay_constant * value
      decayed_value = value - poisson(decay)
      decayed_value > 0 ? decayed_value : 1
    end

    private

    attr_reader :last_updated, :rate

    def decay_constant
      @decay_constant ||= rate * tau
    end

    def tau
      [current_time - last_updated, 1].max
    end

    def poisson(value)
      Poisson.new(value).sample
    end

    def current_time
      @timestamp ||= Time.now.to_i
    end
  end
end
