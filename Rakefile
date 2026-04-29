require "sinatra/activerecord/rake"
require_relative "config/environment"

namespace :db do
  task :prepare do
    Rake::Task["db:create"].invoke if ActiveRecord::Base.connection_db_config.configuration_hash[:database] != ":memory:"
    Rake::Task["db:migrate"].invoke
  end
end
