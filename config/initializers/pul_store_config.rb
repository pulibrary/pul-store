
Hydra::FileCharacterization.configure do |config|
  if Rails.env.production?
    config.tool_path(:fits, '/opt/install/fits-0.8.0/fits.sh')
  else
    config.tool_path(:fits, Rails.root.join(PUL_STORE_CONFIG['fits_dir'], 'fits.sh'))
  end
end

Hydra::Derivatives.kdu_compress_recipes = PUL_STORE_CONFIG['jp2_recipes']
