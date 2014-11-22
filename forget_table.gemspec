Gem::Specification.new do |s|
  s.name = "forget_table"
  s.version = "0.0.0"
  s.date = "2014-02-02"
  s.summary = "Forget table in ruby"
  s.description = "An implementation of http://word.bitly.com/post/41284219720/forget-table in ruby"
  s.authors = ["Nicolò Calcavecchia"]
  s.email = "calcavecchia@gmail.com"
  s.license = "MIT"
  s.files = [
    "lib/forget_table.rb",
    "lib/forget_table/distribution.rb",
    "lib/forget_table/decay.rb",
    "lib/forget_table/decrementer.rb",
    "lib/forget_table/poisson.rb",
  ]

  s.add_development_dependency("rspec", "~> 3.0.0")
  s.add_runtime_dependency("redis", "~> 3.0")
  s.add_development_dependency("rake")
end

