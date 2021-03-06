# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# Capybara integration
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {timeout: 60})
end

Capybara.javascript_driver = :poltergeist
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

TEST_BARCODES = YAML.load_file(Rails.root.join('spec/fixtures/test_barcodes.yml'))

ActiveFedora::Base.delete_all

RSpec.configure do |config|

  config.infer_spec_type_from_file_location!

  # config.before(:suite) do 
  require "#{Rails.root}/db/seeds.rb"
  PulStore::Project.delete_all
  projects = YAML.load_file("#{Rails.root}/db/fixtures/projects.yml")
  projects.map { |project| PulStore::Project.create(project)  }

  # end
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.include Capybara::DSL

  ### Include Devise test helpers
  config.include Devise::TestHelpers, type: :controller
  config.include Devise::TestHelpers, type: :view
  config.include Warden::Test::Helpers

end
