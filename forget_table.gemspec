Gem::Specification.new do |s|
  s.name = "forget_table"
  s.version = "0.0.2"
  s.date = "2014-11-22"
  s.homepage = "https://github.com/ncalca/forgettable"
  s.summary = "Keep track of dynamically changing categorical distribution"
  s.description = "An implementation of http://word.bitly.com/post/41284219720/forget-table in ruby"
  s.authors = ["Nicolò Calcavecchia"]
  s.email = "calcavecchia@gmail.com"
  s.license = "MIT"

  s.files = [
    "lib/forget_table.rb",
    "lib/forget_table/configuration.rb",
    "lib/forget_table/decay.rb",
    "lib/forget_table/decrementer.rb",
    "lib/forget_table/distribution.rb",
    "lib/forget_table/distribution_decrementer.rb",
    "lib/forget_table/distribution_keys.rb",
    "lib/forget_table/poisson.rb",
    "lib/forget_table/weighted_distribution.rb",

    "spec/spec_helper.rb",
    "spec/forget_table/decay_spec.rb",
    "spec/forget_table/decrementer_spec.rb",
    "spec/forget_table/distribution_decrementer_spec.rb",
    "spec/forget_table/distribution_spec.rb",
    "spec/forget_table/poisson_spec.rb",
    "spec/forget_table/weighted_distribution_spec.rb",
    "spec/integration/integration_spec.rb",
  ]

  s.add_runtime_dependency("redis", "~> 3.0")

  s.add_development_dependency("rspec", "~> 3.0")
  s.add_development_dependency("rake", "~> 0.3")
  s.add_development_dependency("fakeredis")
end

