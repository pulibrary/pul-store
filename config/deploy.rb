# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'pul-store'
set :repo_url, 'git@github.com:pulibrary/pul-store.git'
#set :branch, 'master'

ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, '/opt/pul-store'
set :scm, :git

# set :format, :pretty
set :log_level, :debug
# set :pty, true

#set :ssh_options, {
#  verbose: :debug
#}

shared_path = "#{:deploy_to}/shared"
#set :assets_prefix, '#{shared_path}/public'

## removing the following from linked files for the time being
# config/redis.yml config/devise.yml config/resque_pool.yml, config/recipients_list.yml, log/resque-pool.stderr.log log/resque-pool.stdout.log

set :linked_files, %w{config/role_map.yml config/pul_store.yml config/database.yml config/role_map_production.yml config/fedora.yml config/solr.yml config/initializers/secret_token.rb noid-minter-state lae-box-counter-state} 
set :linked_dirs, %w{tmp/pids tmp/cache tmp/sockets}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

# See https://github.com/sshingler/capistrano-resque#in-your-deployrb
#role :resque_worker, 'localhost:6379'
#role :resque_scheduler, 'localhost:6379'
set :workers, { "hydra" => 1 }
set :resque_environment_task, true
set :resque_log_file, "log/resque.log"
set :resque_redirection, ">> log/resque.log 2>> log/resque.log"

task :make_noid_state_files do
  execute "touch #{shared_path}/noid-minter-state"
  execute "touch #{shared_path}/lae-box-counter-state"
end

namespace :deploy do

  desc 'Restart application'
  after :cleanup, :restart do
    on roles(:web), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute "touch #{release_path}/tmp/restart.txt"
    end
    'resque:restart'
      
  end


  #before "deploy:cold", "make_noid_state_files" # untested!
  #TODO this should part of cap deploy:cold
  #
  #desc 'Set Solr Configuration'
  #after :cleanup, :set_solr_configuration do
  # whatever you need to do
  #  on roles(:web), in: :sequence, wait: 5 do
  #    execute "ln -sf #{release_path}/solr_conf/conf/schema.xml /opt/solr/$HYDRA_NAME/collection1/conf/schema.xml"
  #    execute "ln -sf #{release_path}/solr_conf/conf/solrconfig.xml /opt/solr/$HYDRA_NAME/collection1/conf/solrconfig.xml"
  #  end
  #end

#  after :restart, :kill_resque_pool do
#    on roles(:web), in: :sequence, wait: 5 do
#      # Shuts down resque_pool master
#      execute "export master_pid=$(cat #{shared_path}/tmp/pids/resque-pool.pid) && kill -QUIT $master_pid"
#    end
#  end

#  after :kill_resque_pool, :start_resque_pool do
#    on roles(:web), in: :sequence, wait: 5 do
      # Starts a new resque_pool master
#      execute "cd #{release_path} && bundle exec resque-pool -d -E production -c config/resque_pool.yml -e #{shared_path}/log/resque-pool.stderr.log -o #{shared_path}/log/resque-pool.stdout.log"
#    end
#  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      #within release_path do
      #  execute :rake, 'cache:clear'
      #end
    end
  end

  after :finishing, 'deploy:cleanup'

end

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

#namespace :deploy do

#  desc 'Restart application'
#  task :restart do
#    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
#    end
#  end

#  after :publishing, :restart

#  after :restart, :clear_cache do
#    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
#    end
#  end

#end
