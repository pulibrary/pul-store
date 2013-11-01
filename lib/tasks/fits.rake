require File.join(File.dirname(__FILE__), '../../config/environment')

namespace :pulstore do
  namespace :fits do
    desc 'Download fits and place it in the configured directory'
    task download: :environment do
      require File.join(File.dirname(__FILE__), './install_fits.rb')
    end
  end
end
