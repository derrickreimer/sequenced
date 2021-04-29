# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
ENV["RAILS_ROOT"] = File.expand_path("../dummy",  __FILE__)

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

migrate_path = File.expand_path("../dummy/db/migrate/", __FILE__)

if Gem::Version.new(Rails::VERSION::STRING) >= Gem::Version.new("6.0")
  ActiveRecord::MigrationContext.new(migrate_path, ActiveRecord::SchemaMigration).up
else
  ActiveRecord::MigrationContext.new(migrate_path).up
end

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
