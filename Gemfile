source 'https://rubygems.org'

gemspec

gem 'rake', '~> 10.4'
gem 'rack', '~> 1.6'

# presenter
gem 'nokogiri', '~> 1.6'

# mail
gem 'mail', '~> 2.6'
gem 'premailer', '~> 1.8'

# realtime
gem 'websocket_parser', '~> 1.0'
gem 'redis', '~> 3.2'
gem 'concurrent-ruby', '~> 1.0'

group :test do
  gem 'minitest', '~> 5.6'
  gem 'rspec', '~> 3.2'
  gem 'pry', '~> 0.10'

  gem 'simplecov', '~> 0.10', require: false, group: :test
  gem 'simplecov-console', '~> 0.2'

  gem 'rack-test', '~> 0.6', require: 'rack/test'

  gem 'codeclimate-test-reporter', require: false
end

group :development do
  gem 'guard-rspec', '~> 4.6'
  gem 'rubocop', '~> 0.34'
end
