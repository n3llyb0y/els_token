ELS_CONFIG = YAML.load_file("#{Rails.root}/config/els_token.yml")[Rails.env]

class ElsTester  < ActionController::Base
  include ElsToken
  els_config ELS_CONFIG
end