source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.0'

'3.6-stable'.tap do |branch|
  gem 'alchemy_cms',    github: 'AlchemyCMS/alchemy_cms',    branch: branch
  gem 'alchemy-devise', github: 'AlchemyCMS/alchemy-devise', branch: branch
end

# gem 'alchemy-usermanual', github: 'AlchemyCMS/alchemy-usermanual', branch: 'master'

gem 'sass-rails', '~> 5.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks', '~> 2.5'
gem "zurb-foundation"
gem 'pg', '< 1'
gem 'dotenv-rails'

group :development do
  gem 'capistrano-alchemy', github: 'AlchemyCMS/capistrano-alchemy', branch: 'master', require: false
  gem 'pry-byebug'
  gem 'quiet_assets'
  gem 'web-console', '~> 2.0'
end
