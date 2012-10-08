$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "els_token/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "els_token"
  s.version     = ElsToken::VERSION
  s.authors     = ["Neil Chambers"]
  s.email       = ["neil.chambers@teamaol.com"]
  s.homepage    = "http://wiki.office.aol.com/wiki/Els_Token"
  s.summary     = "A simple plugin to assist ELS token validation"
  s.description = "A simple plugin to assist ELS token validation"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]
  
end
