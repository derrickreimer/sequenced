$:.push File.expand_path("../lib", __FILE__)
require "sequenced/version"

Gem::Specification.new do |s|
  s.name        = "sequenced"
  s.version     = Sequenced::VERSION
  s.authors     = ["Derrick Reimer"]
  s.email       = ["derrickreimer@gmail.com"]
  s.homepage    = "https://github.com/djreimer/sequenced"
  s.summary     = "Generate scoped sequential IDs for ActiveRecord models"
  s.description = "Sequenced is a simple Rails 3 engine that generates scoped sequential IDs for ActiveRecord models."

  s.files = `git ls-files`.split("\n")
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.1"
  s.add_development_dependency "sqlite3"
end
