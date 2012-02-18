$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sequenced/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sequenced"
  s.version     = Sequenced::VERSION
  s.authors     = ["Derrick Reimer"]
  s.email       = ["derrickreimer@gmail.com"]
  s.homepage    = "https://github.com/djreimer/sequenced"
  s.summary     = "Generate scoped sequential IDs for ActiveRecord models"
  s.description = "Sequenced is a simple Rails 3 plugin that allows you to generate sequential IDs for ActiveRecord models scoped to a specific model type."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.1"

  s.add_development_dependency "sqlite3"
end
