# rails plugin new china_city --dummy-path=spec/dummy --skip-test-unit --mountable
if ENV['TRAVIS']
  source 'https://rubygems.org'
else
  source 'https://ruby.taobao.org'
end

# Declare your gem's dependencies in china_city.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

gem 'jquery-rails' # fixed: ActionView::Template::Error: couldn't find file 'jquery'
gem 'appraisal'
gem 'pry'
gem 'redis'
# To use debugger
# gem 'debugger'
