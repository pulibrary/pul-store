Hydra::FileCharacterization.configure do |config|
  config.tool_path(:fits, Rails.root.join(cfg['fits_dir'], 'fits.sh'))
end
