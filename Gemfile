source 'http://rubygems.org'

gem 'rails', '3.0.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :development, :test do
  gem 'pg', '0.9.0'
end

group :production do
  gem 'mysql'
end

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

gem "paperclip", '~>2.3.5'
gem "hoptoad_notifier", '~>2.4.4'
gem "will_paginate", '~> 2.3.8'
gem "backports"
gem "devise", '1.1.5'
gem "delayed_job", '~>2.1.0'
gem "json" # Somewhere this is required..
gem "message_block"
gem "haml-rails"

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end

group :development, :test do
  gem "rspec-rails", '>= 2.3.1'
  gem "factory_girl_rails"
  gem "autotest"
  gem "wirble"
end

group :test do
  gem "webmock", :require => "webmock/rspec"
  gem "delorean"
  gem "spork", :git => "git://github.com/chrismdp/spork.git"
end

group :development do
  gem "mongrel"
end
