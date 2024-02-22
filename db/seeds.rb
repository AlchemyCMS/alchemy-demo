require "dotenv/load"
require "demo/alchemy_picture_seeder"

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
  content_block: 14,
}.each do |element_name, picture_id|
  Alchemy::Ingredients::Picture.joins(:element)
    .where(alchemy_elements: { name: element_name })
    .update_all(related_object_id: picture_id, related_object_type: "Alchemy::Picture")
end

# Video assigments
Alchemy::Ingredients::Text.joins(:element)
  .where(alchemy_elements: { name: "video_slide" })
  .update_all(value: "225795837")

puts "\nSeeding Users"
puts "-------------"

# Admin user
if ENV["ADMIN_LOGIN"]
  Alchemy.user_class.create!(
    login: ENV["ADMIN_LOGIN"],
    email: ENV["ADMIN_EMAIL"],
    password: ENV["ADMIN_PASSWORD"],
    password_confirmation: ENV["ADMIN_PASSWORD"],
    alchemy_roles: %w(admin),
  )
  puts "== Created admin user"
end

# Demo user
Alchemy.user_class.create!(
  login: "demo",
  email: "demo@example.com",
  password: "demo123",
  password_confirmation: "demo123",
  alchemy_roles: %w(demo),
)
puts "== Created demo user"

# Menus

puts "\nSeeding Menus"
puts "-------------"

YAML.load_file("./db/seeds/alchemy/pages.yml", permitted_classes: [Date]).each do |page|
  if page["layoutpage"]
    name = "Footer Navigation"
    type = "footer_navigation"
  else
    name = "Main Navigation"
    type = "main_navigation"
  end

  parent_page = Alchemy::Page.find_by!(name: page["name"], page_layout: page["page_layout"])
  parent = Alchemy::Node.create!(
    name: name,
    menu_type: type,
    site: parent_page.site,
    language: parent_page.language,
  )
  puts "== Created menu: #{parent.name}"

  if page["children"]
    page["children"].each do |child|
      child_page = Alchemy::Page.find_by!(name: child["name"], page_layout: child["page_layout"])
      Alchemy::Node.create!(
        parent: parent,
        page: child_page,
        site: parent.site,
        language: parent.language,
      )
      puts "== Created menu entry: #{child_page.name}"
    end
  else
    Alchemy::Node.create!(
      parent: parent,
      url: "/admin",
      name: "Admin Login",
      site: parent.site,
      language: parent.language,
    )
    puts "== Created menu entry: Admin Login"
  end
end

Alchemy::Page.all.each(&:publish!)
