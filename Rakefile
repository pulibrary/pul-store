# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

PulStore::Application.load_tasks

# CI Jetty
APP_ROOT= File.dirname(__FILE__)
require 'jettywrapper'

desc "Run Continuous Integration"
task :ci => ['jetty:config'] do
  jetty_params = Jettywrapper.load_config
  error = nil
  error = Jettywrapper.wrap(jetty_params) do
    Rake::Task['spec'].invoke
  end
  raise "test failures: #{error}" if error

  Rake::Task["doc"].invoke

end

task :default => [:ci]
