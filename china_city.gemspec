$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "china_city/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "china_city"
  s.version     = ChinaCity::VERSION
  s.authors     = ["saberma"]
  s.email       = ["mahb45@gmail.com"]
  s.homepage    = "https://github.com/saberma/china_city"
  s.summary     = ""
  s.description = ""

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.0.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
