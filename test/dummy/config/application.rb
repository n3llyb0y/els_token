require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require
require "els_token"

module Dummy
  class Application < Rails::Application

    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.assets.enabled = true
    config.assets.version = '1.0'
    config.cache_store =  :memory_store
    #, :size => 100.megabytes
    #, :namespace => "els_identity", :expires_in => 1200
  end
end

