require 'forget_table/distribution_decrementer'

module ForgetTable

  # Implements the decay of values in the given distribution.
  class Decrementer

    # TODO: maybe avoid passing redis here
    def initialize(redis, last_updated_key, hits_count_key, weighted_distribution)
      @redis = redis
      @last_updated_key = last_updated_key
      @hits_count_key = hits_count_key
      @weighted_distribution = weighted_distribution
    end

    def run!
      decremented_distribution = distribution_decrementer.decrement
      run_pipeline(decremented_distribution)
    end

    private

    attr_reader :redis, :last_updated_key, :hits_count_key, :weighted_distribution

    # Updates:
    # 1. the weighted distribution with the new distribution
    # 2. the total number of hits for the distribution with the new count
    # 3. the last_updated_at value with the current time

    def run_pipeline(distribution)
      redis.pipelined do
        redis.zadd(distribution.name, distribution.bins.to_a.map(&:reverse))
        redis.set(hits_count_key, distribution.hits_count)
        redis.set(last_updated_key, Time.now.to_i)
      end
    end

    def distribution_decrementer
      last_updated_at = Integer(@redis.get(last_updated_key))
      distribution_decrementer = DistributionDecrementer.new(
        weighted_distribution: weighted_distribution,
        last_updated_at: last_updated_at
      )
    end
  end
end
