require File.join(File.dirname(__FILE__), '../../config/environment')

namespace :pulstore do
  namespace :fits do
    task download: :environment do
      # Download fits and place it in the configured directory
      require File.join(File.dirname(__FILE__), './install_fits.rb')
    end
  end
end
