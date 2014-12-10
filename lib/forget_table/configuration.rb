module ForgetTable

  class Configuration

    def self.decay_rate
      @decay_rate || ForgetTable::Decay::DEFAULT_DECAY_RATE
    end

    def self.decay_rate=(value)
      @decay_rate = value
    end

  end
end
