require "bundler/setup"
Bundler.require(:default)

require "minitest/autorun"
require "active_record"

adapter = ENV["ADAPTER"].to_sym || :postgresql
puts "Using #{adapter}"

database_yml = File.expand_path("support/database.yml", __dir__)
ActiveRecord::Base.configurations = YAML.load_file(database_yml)
ActiveRecord::Base.establish_connection(adapter)

require_relative "support/schema"
require_relative "support/models"
