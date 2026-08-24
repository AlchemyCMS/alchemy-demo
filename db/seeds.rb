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

# Give each gallery image one of the seeded photos (round-robin)
gallery_pictures = Alchemy::Picture.order(:id).to_a
if gallery_pictures.any?
  Alchemy::Ingredients::Picture.joins(:element)
    .where(alchemy_elements: { name: "gallery_image" })
    .each_with_index do |ingredient, index|
      ingredient.update!(related_object: gallery_pictures[index % gallery_pictures.size])
    end
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

# Gallery-specific intro on the Galleries page (concept_intro is shared, so its
# default belongs to the Elements page; override it here)
Alchemy::Element.where(name: "concept_intro")
  .joins(page_version: :page)
  .where(alchemy_pages: { urlname: "galleries" })
  .find_each do |element|
    element.ingredient_by_role(:eyebrow)&.update!(value: "Core concept")
    element.ingredient_by_role(:headline)&.update!(value: "Nesting & Galleries")
    element.ingredient_by_role(:lead)&.update!(value:
      "<p>Some Elements are <strong>nestable</strong> — they hold child Elements. This gallery nests gallery_image Elements, each a Picture cropped to a fixed ratio and served responsively.</p>")
  end

# Blog: distinct article headers (+ a photo each) and the overview intro
blog_photos = Alchemy::Picture.order(:id).to_a
[
  ["blog/composing-content-with-elements", "Composing content with Elements", Date.new(2026, 6, 2),
    "<p>How a page is assembled from reusable Elements, each made of typed Ingredients.</p>"],
  ["blog/cropping-and-responsive-images", "Cropping and responsive images", Date.new(2026, 6, 9),
    "<p>Using Picture ingredients with cropping, srcset and sizes for sharp, fast images.</p>"],
  ["blog/nesting-elements-in-a-gallery", "Nesting elements in a gallery", Date.new(2026, 6, 16),
    "<p>Nestable Elements let editors build galleries and other repeating structures.</p>"],
].each_with_index do |(urlname, title, date, intro), index|
  Alchemy::Element.where(name: "post_header")
    .joins(page_version: :page)
    .where(alchemy_pages: { urlname: urlname })
    .find_each do |header|
      header.ingredient_by_role(:headline)&.update!(value: title)
      header.ingredient_by_role(:published_at)&.update!(value: date)
      header.ingredient_by_role(:intro)&.update!(value: intro)
      header.ingredient_by_role(:author)&.update!(value: "The Alchemy Team")
      header.ingredient_by_role(:image)&.update!(related_object: blog_photos[index % blog_photos.size]) if blog_photos.any?
    end
end

Alchemy::Element.where(name: "concept_intro")
  .joins(page_version: :page)
  .where(alchemy_pages: { urlname: "blog" })
  .find_each do |element|
    element.ingredient_by_role(:eyebrow)&.update!(value: "Guide")
    element.ingredient_by_role(:headline)&.update!(value: "From the blog")
    element.ingredient_by_role(:lead)&.update!(value:
      "<p>A blog is just Pages: a parent overview and child article pages. This page teases each child's post_header — its headline, date and intro.</p>")
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
