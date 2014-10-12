module ForgetTable

  class DistributionKeys
    attr_reader :distribution_name

    def initialize(distribution_name)
      @distribution_name = distribution_name
    end

    def last_updated_at
      "#{distribution_name}_t"
    end

    def hits_count
      "#{distribution_name}_z"
    end
  end
end
