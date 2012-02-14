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
  s.description = <<-EOD
    This is a rails plugin to help with ELS Token Validation.
    include the ElsToken module in your application controller and
    set optional fake_it and els_uri properties

    call get_els_token to extract the user cdid
    or els_authenticated?(username,password) to get
    a boolean
    EOD

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.1.0"

  s.add_development_dependency "sqlite3"
end
