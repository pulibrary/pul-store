require File.join(File.dirname(__FILE__), '../../config/environment')
# require 'database_cleaner'

namespace :pulstore do
  namespace :languages do

    task :delete do
      # DatabaseCleaner.strategy = :truncation
      # DatabaseCleaner.clean
    end

    task download: :environment do
      require File.join(File.dirname(__FILE__), './get_languages.rb')
    end

    # should this be seeds.rb?
    # task load: :environment do
    # end


    task :reload do
      Rake::Task['pulstore:languages:delete'].invoke
      Rake::Task['pulstore:languages:load'].invoke
    end

  end
end
