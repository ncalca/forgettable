module ForgetTable

  class Poisson
    attr_reader :average

    def initialize(average)
      raise ArgumentError, "average must be > 0 , #{average} given" if average <= 0
      @average = average
    end

    def sample
      @sample ||= extract_sample
    end

    private

    # Returns an Integer extracted from a Poisson
    # distribution with average `average`.
    # Implemented according to the Knuth algorithm.
    def extract_sample
      l = Math.exp(-average)
      k = 0
      p = 1
      while p > l do
        k += 1
        p *= random_in_0_1
      end
      k - 1
    end

    def random_in_0_1
      random.rand(1.0)
    end

    def random
      @@rand ||= Random.new
    end
  end
end

