module ForgetTable

  # Represents a categorigal distribution composed by bins with scores.
  #
  # A distribution is instantiated with the following parameters:
  # - name: the name of the distribution
  # - redis: the redis client
  class Distribution
    attr_reader :name

    def initialize(name, redis)
      @name = name
      @redis = redis
    end

    # Increments the bin score by the given amount.
    # params:
    # - bin
    # - amount
    def increment(bin, amount)
      @redis.zincrby(name, amount, bin)

      # Increment the total number of hits
      stored_bins = @redis.incrby(hits_count_key, 1)

      if stored_bins == 1
        # Set the initial timestamp if never set
        @redis.set(last_updated_key, Time.now.to_i)
      end
    end

    # Returns the list of bins in the distribution.
    # Params:
    # - number_of_bins
    # - options
    def distribution(number_of_bins = -1, options = {})
      decrement!

      stop_bin = (number_of_bins == -1) ? -1 : (number_of_bins - 1)
      @redis.zrevrange(name, 0, stop_bin, options)
    end

    # Returns the score for the given bin
    def score_for_bin(bin)
      decrement!

      @redis.zscore(name, bin)
    end

    def last_updated
      @redis.get(last_updated_key)
    end

    def hits_count
      @redis.get(hits_count_key)
    end

    private

    def last_updated_key
      "#{name}_t"
    end

    # Represent the redis key associated with this distribution
    # used to count the total number of hits.
    def hits_count_key
      "#{name}_z"
    end

    def decrement!
      decrementer.run!
    end

    def decrementer
      @decrementer ||= Decrementer.new(@redis, name, last_updated_key, hits_count_key)
    end
  end
end
