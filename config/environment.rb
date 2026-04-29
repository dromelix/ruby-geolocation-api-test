ENV["RACK_ENV"] ||= "development"

require "bundler/setup"
Bundler.require(:default, ENV["RACK_ENV"].to_sym)

Dotenv.load if ENV["RACK_ENV"] != "production"

require "json"
require "uri"
require "resolv"

require_relative "../app/models/geolocation_record"
require_relative "../app/errors/api_error"
require_relative "../app/services/geolocation/providers/base_provider"
require_relative "../app/services/geolocation/providers/ipstack_provider"
require_relative "../app/services/geolocation/provider_factory"
require_relative "../app/services/geolocation/normalizer"
require_relative "../app/services/geolocation/fetch_and_store"
require_relative "../app/api"
