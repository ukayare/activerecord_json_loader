$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_record'
require 'activerecord_json_loader'
require "database_rewinder"
require_relative "test_model"
RSpec.configure do |config|
  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  config.before(:suite) do
    ActiveRecord::Tasks::DatabaseTasks.db_dir = File.expand_path "..", __FILE__
    ActiveRecord::Tasks::DatabaseTasks.root   = File.expand_path "../..", __FILE__
    ActiveRecord::Tasks::DatabaseTasks.env    = "test"

    configuration = ActiveRecord::Base.configurations["test"]
    ActiveRecord::Tasks::DatabaseTasks.drop(configuration)
    ActiveRecord::Tasks::DatabaseTasks.create(configuration)

    ActiveRecord::Tasks::DatabaseTasks.load_schema_for configuration, :ruby

    DatabaseRewinder["test"]
  end

  config.after(:each) do
    DatabaseRewinder.clean
  end

  config.after(:suite) do
    configuration = ActiveRecord::Base.configurations["test"]
    ActiveRecord::Tasks::DatabaseTasks.drop(configuration)
  end
end
