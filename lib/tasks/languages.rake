require File.join(File.dirname(__FILE__), '../../config/environment')
# require 'database_cleaner'

namespace :pulstore do
  namespace :languages do

    desc 'NOT IMPLEMENTED Delete ISO 639 Languages from database'
    task :delete do
      # DatabaseCleaner.strategy = :truncation
      # DatabaseCleaner.clean
    end

    desc 'Download ISO 639 Languages from id.loc.gov'
    task download: :environment do
      require File.join(File.dirname(__FILE__), './get_languages.rb')
    end

    # should this be seeds.rb?
    desc 'NOT IMPLEMENTED Load ISO 639 Languages to the database'
    task load: :environment do
    end

    desc 'NOT IMPLEMENTED Reload ISO 639 Languages to the database'
    task :reload do
      Rake::Task['pulstore:languages:delete'].invoke
      Rake::Task['pulstore:languages:load'].invoke
    end

  end
end
