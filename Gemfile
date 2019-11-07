source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby `cat .ruby-version`.chomp.tr('ruby-', '')

'master'.tap do |branch|
  gem 'alchemy_cms',        github: 'tvdeyen/alchemy_cms',           branch: 'add-menus'
  gem 'alchemy-devise',     github: 'AlchemyCMS/alchemy-devise',     branch: branch
  gem 'alchemy_i18n',       github: 'AlchemyCMS/alchemy_i18n',       branch: branch
  gem 'alchemy_cloudinary', github: 'AlchemyCMS/alchemy_cloudinary', branch: branch
  gem 'alchemy-graphql',    github: 'AlchemyCMS/alchemy-graphql',    branch: branch
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.0'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sassc-rails', '~> 2.1'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
gem "zurb-foundation", "~> 4.3.2"

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Reset the demo
gem "database_cleaner", "~> 1.7", require: false
gem 'dotenv-rails', '~> 2.7'

gem "graphiql-rails", "1.4.8"

group :development, :test do
  gem 'pry-rails'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :production do
  gem 'rack-cache', '~> 1.8'
  gem 'dalli', '~> 2.7'
  gem 'kgio', '~> 2.11'
  gem 'lograge', '~> 0.10'
end

gem "sentry-raven", "~> 2.9"

gem "newrelic_rpm", "~> 6.2"
