module ForgetTable

  class Decay

    DEFAULT_DECAY_RATE = 0.2

    # - last_updated: timestamp of the last update
    # - rate:         the rate of the decay (optional)
    def initialize(last_updated, rate = DEFAULT_DECAY_RATE)
      @last_updated = last_updated
      @rate = rate
    end

    def decay_value(value)
      decayed_value = value - decay_for(value)
      decayed_value > 0 ? decayed_value : 1
    end

    private

    attr_reader :last_updated, :rate

    def decay_for(value)
      poisson(decay_factor * value)
    end

    def decay_factor
      rate * tau
    end

    # Time since last update
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
