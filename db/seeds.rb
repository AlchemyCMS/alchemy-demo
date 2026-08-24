require "dotenv/load"
require "demo/alchemy_picture_seeder"

# Pictures
Demo::AlchemyPictureSeeder.seed!

# Pages
Alchemy::Seeder.seed!

# Picture assignments (skipped when pictures were not seeded, e.g. in tests)
featured_picture = Alchemy::Picture.find_by(name: "photo-03") || Alchemy::Picture.first
if featured_picture
  Alchemy::Ingredients::Picture.joins(:element)
    .where(alchemy_elements: { name: "image_text" })
    .find_each { |ingredient| ingredient.update!(related_object: featured_picture) }
end

# Video assigments
Alchemy::Ingredients::Text.joins(:element)
  .where(alchemy_elements: { name: "video_slide" })
  .update_all(value: "225795837")

# Distinct content for the Home concept cards (autogenerate creates identical ones)
[
  ["Pages & Page Layouts", "<p>Every Page uses a Page Layout that decides which Elements it may contain.</p>"],
  ["Elements", "<p>An Element is a reusable content block you place on a Page.</p>"],
  ["Ingredients", "<p>Ingredients are the typed fields inside an Element — Text, Richtext, Picture, Link and more.</p>"],
].each_with_index do |(title, description), index|
  card = Alchemy::Element.where(name: "concept_card").order(:position)[index]
  next unless card

  card.ingredient_by_role(:title)&.update(value: title)
  card.ingredient_by_role(:description)&.update(value: description)
end

puts "\nSeeding Users"
puts "-------------"

# Admin user
if ENV["ADMIN_LOGIN"]
  Alchemy.config.user_class.create!(
    login: ENV["ADMIN_LOGIN"],
    email: ENV["ADMIN_EMAIL"],
    password: ENV["ADMIN_PASSWORD"],
    password_confirmation: ENV["ADMIN_PASSWORD"],
    alchemy_roles: %w(admin),
  )
  puts "== Created admin user"
end

# Demo user
Alchemy.config.user_class.create!(
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

puts "\nPublish Pages"
puts "-------------"
Alchemy::Page.all.each do |page|
  Alchemy::PublishPageJob.perform_now(page.id, public_on: Time.current)
  puts "== Published Page: #{page.name}"
end

puts "\nSeeding finished 🎉"
