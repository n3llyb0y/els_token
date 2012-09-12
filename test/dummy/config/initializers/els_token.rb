ELS_CONFIG = YAML.load_file("#{Rails.root}/config/els.yml")["test"]

class ElsTester  < ActionController::Base
  include ElsToken
  els_config ELS_CONFIG
end