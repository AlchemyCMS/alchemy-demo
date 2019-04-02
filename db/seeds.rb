require 'dotenv/load'

# Pages
Alchemy::Seeder.seed!

# Admin user
if ENV['ADMIN_LOGIN']
  Alchemy.user_class.create!(
    login: ENV['ADMIN_LOGIN'],
    email: ENV['ADMIN_EMAIL'],
    password: ENV['ADMIN_PASSWORD'],
    password_confirmation: ENV['ADMIN_PASSWORD'],
    alchemy_roles: %w(admin)
  )
  puts "== Created admin user"
end

# Demo user
Alchemy.user_class.create!(
  login: 'demo',
  email: 'demo@example.com',
  password: 'demo123',
  password_confirmation: 'demo123',
  alchemy_roles: %w(demo)
)
puts "== Created demo user"
