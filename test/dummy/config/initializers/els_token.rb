ELS_CONFIG = YAML.load_file("#{Rails.root}/config/els.yml")["test"]

class ElsTester
  include ElsToken
  els_config ELS_CONFIG
end