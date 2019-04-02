require 'dotenv/load'
require 'demo/alchemy_picture_seeder'

# Pictures
Demo::AlchemyPictureSeeder.seed!

# Pages
Alchemy::Seeder.seed!

# Picture assigments
{
  gallery_picture: 1,
  image_slide: 4,
  image_teaser: 7,
  blog_post: 11,
  category_intro: 13,
  content_block: 14
}.each do |element_name, picture_id|
  Alchemy::EssencePicture.joins(:element)
    .where(alchemy_elements: {name: element_name})
    .update_all(picture_id: picture_id)
end

# Video assigments
Alchemy::EssenceText.joins(:element)
  .where(alchemy_elements: {name: 'video_slide'})
  .update_all(body: '225795837')

Alchemy::EssenceText.joins(:element)
  .where(alchemy_elements: {name: 'footer_links_link'})
  .update_all(body: 'Admin Login', link: '/admin')

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
