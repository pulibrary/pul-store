
Hydra::FileCharacterization.configure do |config|
  if Rails.env.production?
    config.tool_path(:fits, '/usr/local/bin/fits')
  else
    config.tool_path(:fits, Rails.root.join(PUL_STORE_CONFIG['fits_dir'], 'fits.sh'))
  end
end

Hydra::Derivatives.kdu_compress_recipes = PUL_STORE_CONFIG['jp2_recipes']
