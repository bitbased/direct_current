$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "direct_current/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "direct_current"
  s.version     = DirectCurrent::VERSION
  s.authors     = ["Brant Wedel"]
  s.email       = ["info@bitbased.net"]
  s.homepage    = "http://github.com/bitbased"
  s.summary     = "Static content engine"
  s.description = "Fully charged static content"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "high_voltage"

  s.add_development_dependency "sqlite3"
end
