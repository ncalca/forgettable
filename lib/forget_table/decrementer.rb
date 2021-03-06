require 'forget_table/distribution_decrementer'

module ForgetTable

  class Decrementer

    def initialize(redis, weighted_distribution)
      @redis = redis
      @weighted_distribution = weighted_distribution
    end

    def run!
      decremented_distribution = distribution_decrementer.decremented_distribution
      updated_redis(decremented_distribution)
    end

    private

    attr_reader :redis, :weighted_distribution

    # Updates:
    # 1. the weighted distribution with the new distribution
    # 2. the total number of hits for the distribution with the new count
    # 3. the last_updated_at value with the current time

    def updated_redis(distribution)
      redis.pipelined do
        redis.zadd(distribution.name, distribution.bins.to_a.map(&:reverse))
        redis.set(hits_count_key, distribution.hits_count)
        redis.set(last_updated_at_key, Time.now.to_i)
      end
    end

    def distribution_decrementer
      last_updated_at = Integer(@redis.get(last_updated_at_key))
      distribution_decrementer = DistributionDecrementer.new(
        weighted_distribution: weighted_distribution,
        last_updated_at: last_updated_at
      )
    end

    def distribution_keys
      DistributionKeys.new(weighted_distribution.name)
    end

    def hits_count_key
      distribution_keys.hits_count
    end

    def last_updated_at_key
      distribution_keys.last_updated_at
    end
  end
end
