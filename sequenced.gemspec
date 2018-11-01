$:.push File.expand_path("../lib", __FILE__)
require "sequenced/version"

Gem::Specification.new do |s|
  s.name        = "sequenced"
  s.version     = Sequenced::VERSION
  s.authors     = ["Derrick Reimer"]
  s.licenses    = ['MIT']
  s.email       = ["derrickreimer@gmail.com"]
  s.homepage    = "https://github.com/djreimer/sequenced"
  s.summary     = "Generate scoped sequential IDs for ActiveRecord models"
  s.description = "Sequenced is a gem that generates scoped sequential IDs for ActiveRecord models."

  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }

  s.add_dependency "activesupport", ">= 3.0"
  s.add_dependency "activerecord", ">= 3.0"
  s.add_development_dependency "rails", ">= 3.1"
end
