module ForgetTable

  # Implements the decay of values in the given distribution.
  class Decrementer

    # TODO: maybe avoid passing redis here
    def initialize(redis, distribution_name, last_updated_key, hits_count_key)
      @redis = redis
      @distribution_name = distribution_name
      @last_updated_key = last_updated_key
      @hits_count_key = hits_count_key
    end

    def run!

      existing_values = get_existing_values
      decremented_values = decrement(existing_values.map(&:last))
      new_hits_count = decremented_values.inject(:+)

      keys = existing_values.map(&:first)
      new_values = decremented_values.zip(keys)

      last_updated_at = Time.now.to_i
      run_pipeline(new_values, new_hits_count, last_updated_at)
    end

    private

    attr_reader :redis, :distribution_name, :last_updated_key, :hits_count_key

    def run_pipeline(new_values, new_hits_count, last_updated_at)
      redis.pipelined do
        redis.zadd(distribution_name, new_values)
        redis.set(hits_count_key, new_hits_count)
        redis.set(last_updated_key, last_updated_at)
      end
    end

    def decrement(values)
      last_updated = Integer(@redis.get(last_updated_key))
      decay = Decay.new(values, last_updated)
      decay.decayed_values
    end

    def get_existing_values
      redis.zrevrange(distribution_name, 0, -1, with_scores: true)
    end
  end

end
