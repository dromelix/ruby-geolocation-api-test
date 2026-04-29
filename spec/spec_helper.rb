ENV["RACK_ENV"] = "test"
ENV["API_AUTH_TOKEN"] = "test-token"
ENV["GEOLOCATION_PROVIDER"] = "ipstack"
ENV["IPSTACK_API_KEY"] = "test-ipstack-key"

require_relative "../config/environment"
require "rack/test"
require "webmock/rspec"
require "database_cleaner/active_record"

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:suite) do
    ActiveRecord::Base.establish_connection(:test)
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define do
      suppress_messages do
        load File.expand_path("../db/schema.rb", __dir__)
      rescue StandardError
        # If schema doesn't exist yet, run migrations once for test setup.
        migration_paths = [File.expand_path("../db/migrate", __dir__)]
        ActiveRecord::MigrationContext.new(migration_paths, ActiveRecord::SchemaMigration).migrate
      end
    end
  end

  config.before do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end
end

def app
  GeolocationAPI
end
