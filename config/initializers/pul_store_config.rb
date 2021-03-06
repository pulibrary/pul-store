
Hydra::FileCharacterization.configure do |config|
  if Rails.env.production?
    config.tool_path(:fits, '/usr/local/bin/fits')
  else
    config.tool_path(:fits, Rails.root.join(PUL_STORE_CONFIG['fits_dir'], 'fits.sh'))
  end
end

Hydra::Derivatives.kdu_compress_recipes = PUL_STORE_CONFIG['jp2_recipes']

if Rails.env.production?
  Deprecation.default_deprecation_behavior = :silence
end

Solrizer::FieldMapper.descriptors << PulStore::Mappers

Resque.logger = Logger.new("#{Rails.root}/log/resque_#{Date.today.strftime('%Y-%m-%d')}.log")
Resque.logger.level = Logger::INFO
