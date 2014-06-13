rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

config = YAML::load_file(rails_root + '/config/resque.yml')
Resque.redis = config[rails_env]

Resque.inline = rails_env == 'test'
Resque.redis.namespace = "pul_store:#{rails_env}"
