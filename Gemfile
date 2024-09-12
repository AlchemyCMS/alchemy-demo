source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> #{`cat .ruby-version`.chomp.tr("ruby-", "")}"

gem "alchemy_cms", "~> 7.3.0"
gem "alchemy-devise", "~> 7.3.0"
gem "alchemy_i18n", "~> 4.2.0"
gem "alchemy_cloudinary", "~> 3.0"
gem "alchemy-sentry", "~> 1.0"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 7.2.0"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.0"
# Use Puma as the app server
gem "puma", "~> 6.0"
# Use SCSS for stylesheets
gem "sassc-rails", "~> 2.1"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
gem "zurb-foundation", "~> 4.3.2"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

# Reset the demo
gem "database_cleaner", "~> 2.0", require: false
gem "dotenv-rails", "~> 2.7"

# K8s health checks
gem "health_bit", "~> 0.2"

group :development, :test do
  gem "pry-rails"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "listen", ">= 3.0.5"
end

group :production do
  gem "lograge", "~> 0.10"
  # Necessary to compile assets without database connection
  gem "redis", "~> 5.0"
end

gem "newrelic_rpm", "~> 8.0"
