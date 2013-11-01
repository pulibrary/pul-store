namespace :fits do
  desc 'Download fits and place it in the configured directory'
  task :download do
    puts 'Downloading FITS'
    require File.join(File.dirname(__FILE__), 'install_fits.rb')
  end
end
