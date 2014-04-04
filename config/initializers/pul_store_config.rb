Hydra::FileCharacterization.configure do |config|
  config.tool_path(:fits, Rails.root.join(PUL_STORE_CONFIG['fits_dir'], 'fits.sh'))
end

Hydra::Derivatives.kdu_compress_recipes = PUL_STORE_CONFIG['jp2_recipes']
