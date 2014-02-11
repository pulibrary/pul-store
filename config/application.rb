require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

# require "rails/test_unit/railtie"

require File.expand_path('../../lib/ext/marc', __FILE__)

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module PulStore
  class Application < Rails::Application
    
    config.generators do |g|
      g.test_framework :rspec, :spec => true
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
    end

    config.i18n.enforce_available_locales = true
    config.autoload_paths += Dir["#{config.root}/app/models/**/"]

    # config.autoload_paths += Dir["#{config.root}/app/models/concerns/"]
    # config.autoload_paths += Dir["#{config.root}/app/models/"]
    # config.autoload_paths += Dir["#{config.root}/app/models/pul_store/"]
    # config.autoload_paths += Dir["#{config.root}/app/models/pul_store/lae/"]
    # config.autoload_paths += Dir["#{config.root}/app/models/pul_store/concerns/"]
    # config.autoload_paths += Dir["#{config.root}/app/models/pul_store/concerns/pul_store/"]
    # config.autoload_paths += Dir["#{config.root}/app/models/pul_store/datastreams/"]
    # config.autoload_paths += Dir["#{config.root}/app/models/pul_store/datastreams/pul_store/"]
    # config.autoload_paths += Dir["#{config.root}/app/models/pul_store/concerns/pul_store/lae/"]
    # config.autoload_paths += Dir["#{config.root}/app/models/pul_store/datastreams/pul_store/lae"]
    # config.autoload_paths += Dir["#{config.root}/app/models/pul_store/concerns"]
    # config.autoload_paths += Dir["#{config.root}/app/models/pul_store/lib"]
    # config.autoload_paths += Dir["#{config.root}/app/models/pul_store/lib/active_fedora"]
    # config.autoload_paths += Dir["#{config.root}/app/models/pul_store/lib/rdf"]

    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
