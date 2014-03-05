# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
if !Rails.env.production?
 require 'rspec/core/rake_task'
end


PulStore::Application.load_tasks

task :ci do
  # install fits
  Rake::Task['fits:download'].invoke

  require 'jettywrapper'
  jetty_params = Jettywrapper.load_config.merge(
      {:jetty_home => File.expand_path(File.dirname(__FILE__) + '/jetty'),
       :startup_wait => 180,
       :jetty_port => ENV['TEST_JETTY_PORT'] || 8983
      }
  )

  Rake::Task['jetty:unzip'].invoke
  Rake::Task['jetty:config'].invoke
  error = nil
  error = Jettywrapper.wrap(jetty_params) do
    Rake::Task['spec'].invoke
  end


  raise "test failures: #{error}" if error
end

# Rake::Task[:default].prerequisites.clear
task :default => []; Rake::Task[:default].clear
task :default => [:ci]
