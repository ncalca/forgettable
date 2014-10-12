require 'forget_table/decrementer'
require 'forget_table/weighted_distribution'
require 'forget_table/distribution_keys'

module ForgetTable

  # Represents a categorical distribution composed by weighted bins.
  #
  # A distribution is instantiated with the following parameters:
  # - name: the name of the distribution
  # - redis: the redis client that will host the distribution
  #
  # Example of an instance:
  #   distribution: "guitars"
  #     bins: "fender" => 10, "gibson" => 20, "epi" => "30

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
      redis.zincrby(name, amount, bin)

      # Increment the total number of hits
      stored_bins = redis.incrby(hits_count_key, 1)

      if stored_bins == 1
        # Set the initial timestamp if never set
        redis.set(last_updated_at_key, Time.now.to_i)
      end
    end

    # Returns the list of bins in the distribution.
    # Params:
    # - number_of_bins
    # - options
    def distribution(number_of_bins = -1, options = {})
      decrement!

      stop_bin = (number_of_bins == -1) ? -1 : (number_of_bins - 1)
      redis.zrevrange(name, 0, stop_bin, options)
    end

    # Returns the score for the given bin
    def score_for_bin(bin)
      decrement!

      redis.zscore(name, bin)
    end

    def last_updated
      redis.get(last_updated_at_key)
    end

    def hits_count
      redis.get(hits_count_key)
    end

    private
    attr_reader :redis

    def hits_count_key
      distribution_keys.hits_count
    end

    def last_updated_at_key
      distribution_keys.last_updated_at
    end

    def decrement!
      raise "Cannot find distribution #{name}" unless redis.exists(name)

      decrementer.run!
    end

    def decrementer
      @decrementer ||= Decrementer.new(redis, weighted_distribution)
    end

    def weighted_distribution
      bins = Hash[*redis.zrevrange(name, 0, -1, with_scores: true).flatten]
      WeightedDistribution.new(
        name: name,
        bins: bins,
      )
    end

    def distribution_keys
      DistributionKeys.new(name)
    end
  end
end
