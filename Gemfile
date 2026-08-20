source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> #{`cat .ruby-version`.chomp.tr("ruby-", "")}"

gem "alchemy_cms", github: "AlchemyCMS/alchemy_cms", branch: "8.3-stable"
gem "alchemy-devise", "~> 8.0"
gem "alchemy_i18n", "~> 8.3"
gem "alchemy_cloudinary", "~> 4.0"
gem "alchemy-sentry", "~> 2.0"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 8.1.0"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 2.1"
# Use Puma as the app server
gem "puma", "~> 8.0"
# Sprockets asset pipeline (previously pulled in transitively by sassc-rails)
gem "sprockets-rails", "~> 3.5"
# Use Tailwind CSS for the public frontend
gem "tailwindcss-rails", "~> 4.0"
# Import maps + Stimulus for the public frontend
gem "importmap-rails", "~> 2.0"
gem "stimulus-rails", "~> 1.3"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

# Reset the demo
gem "database_cleaner", "~> 2.0", require: false
gem "dotenv-rails", "~> 3.1"

# K8s health checks
gem "health_bit", "~> 0.2"

# Deployment
gem "kamal", "~> 2.0", require: false
gem "thruster", "~> 0.1", require: false
gem "connection_pool", "~> 3.0"  # Pin to 2.x for Rails RedisCacheStore compatibility

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
end

gem "newrelic_rpm", "~> 10.7"
