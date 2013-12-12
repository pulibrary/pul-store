
PUL_STORE_CONFIG = YAML.load_file(Rails.root.join('config', 'pul_store.yml'))[Rails.env]

Hydra::FileCharacterization.configure do |config|
  config.tool_path(:fits, Rails.root.join(PUL_STORE_CONFIG['fits_dir'], 'fits.sh'))
end
