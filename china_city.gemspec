$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "china_city/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "china_city"
  s.version     = ChinaCity::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of ChinaCity."
  s.description = "TODO: Description of ChinaCity."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.0.0"

  s.add_development_dependency "sqlite3"
end
