if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

gem 'alchemy_cms',              github: 'magiclabs/alchemy_cms',            branch: '3.0/backend-redesign'
gem 'alchemy-devise',           github: 'magiclabs/alchemy-devise',         branch: 'master'
gem 'alchemy-usermanual',       github: 'magiclabs/alchemy-usermanual',     branch: 'master'
gem 'non-stupid-digest-assets', github: 'alexspeller/non-stupid-digest-assets', branch: 'master'

gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks', '2.1.0'
gem "zurb-foundation"

group :development do
  gem 'capistrano', '~> 2.15'
  gem 'pry'
  gem 'sqlite3'
  # gem "rails-i18n-debug"
  gem 'quiet_assets'
end

group :production do
  gem 'mysql2'
end
