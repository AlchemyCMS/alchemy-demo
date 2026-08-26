require "dotenv/load"
require "demo/alchemy_picture_seeder"
require "demo/alchemy_attachment_seeder"

# Pictures
Demo::AlchemyPictureSeeder.seed!

# Attachments (audio/video/file for the Ingredients tour page)
Demo::AlchemyAttachmentSeeder.seed!

# Pages
Alchemy::Seeder.seed!

# Picture assignments (skipped when pictures were not seeded, e.g. in tests)
featured_picture = Alchemy::Picture.find_by(name: "photo-03") || Alchemy::Picture.first
if featured_picture
  Alchemy::Ingredients::Picture.joins(:element)
    .where(alchemy_elements: { name: "image_text" })
    .find_each { |ingredient| ingredient.update!(related_object: featured_picture) }
end

# Hero background image (demonstrates the background_image Picture + CSS filter)
hero_photo = Alchemy::Picture.find_by(name: "photo-05") || Alchemy::Picture.first
if hero_photo
  Alchemy::Ingredients::Picture.joins(:element)
    .where(alchemy_elements: {name: "hero"})
    .find_each { |ingredient| ingredient.update!(related_object: hero_photo) }
end

# Give each gallery image one of the seeded photos (round-robin)
gallery_pictures = Alchemy::Picture.where("name LIKE ?", "photo-%").order(:id).to_a
if gallery_pictures.any?
  Alchemy::Ingredients::Picture.joins(:element)
    .where(alchemy_elements: { name: "gallery_image" })
    .each_with_index do |ingredient, index|
      ingredient.update!(related_object: gallery_pictures[index % gallery_pictures.size])
    end
end

# Distinct content for the Home concept cards (autogenerate creates identical ones)
[
  ["Pages & Page Layouts", "<p>Every Page uses a Page Layout that decides which Elements it may contain.</p>", "concept-pages"],
  ["Elements", "<p>An Element is a reusable content block you place on a Page.</p>", "concept-elements"],
  ["Ingredients", "<p>Ingredients are the typed fields inside an Element — Text, Richtext, Picture, Link and more.</p>", "concept-ingredients"],
].each_with_index do |(title, description, illustration_name), index|
  card = Alchemy::Element.where(name: "concept_card").order(:position)[index]
  next unless card

  card.ingredient_by_role(:title)&.update(value: title)
  card.ingredient_by_role(:description)&.update(value: description)
  illustration = Alchemy::Picture.find_by(name: illustration_name)
  card.ingredient_by_role(:illustration)&.update!(related_object: illustration) if illustration
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
blog_photos = Alchemy::Picture.where("name LIKE ?", "photo-%").order(:id).to_a
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

# Contact: wire the form's success page to the Thank you page, and set intros
thanks_page = Alchemy::Page.find_by(urlname: "contact/thank-you")
Alchemy::Element.where(name: "contactform")
  .joins(page_version: :page)
  .where(alchemy_pages: { urlname: "contact" })
  .find_each { |form| form.ingredient_by_role(:success_page)&.update!(related_object: thanks_page) if thanks_page }

Alchemy::Element.where(name: "concept_intro")
  .joins(page_version: :page)
  .where(alchemy_pages: { urlname: "contact" })
  .find_each do |element|
    element.ingredient_by_role(:eyebrow)&.update!(value: "Get in touch")
    element.ingredient_by_role(:headline)&.update!(value: "Contact us")
    element.ingredient_by_role(:lead)&.update!(value:
      "<p>This form uses Alchemy's built-in <strong>Messages</strong> feature. In the demo it validates and confirms without sending real email.</p>")
  end

Alchemy::Element.where(name: "concept_intro")
  .joins(page_version: :page)
  .where(alchemy_pages: { urlname: "contact/thank-you" })
  .find_each do |element|
    element.ingredient_by_role(:eyebrow)&.update!(value: "Thank you")
    element.ingredient_by_role(:headline)&.update!(value: "Message received")
    element.ingredient_by_role(:lead)&.update!(value:
      "<p>Thanks for reaching out — we'll be in touch. No real email was sent in this demo.</p>")
  end

# Events: seed records for the custom Events module and wire the demo page
events_data = [
  ["Alchemy Contributor Summit", "Berlin, Germany", Time.utc(2026, 3, 14, 9), Time.utc(2026, 3, 15, 17),
    "Two days of talks and hacking with the Alchemy core team and contributors."],
  ["Ruby on Rails Meetup", "Cologne, Germany", Time.utc(2026, 5, 6, 18, 30), Time.utc(2026, 5, 6, 21),
    "A casual evening of lightning talks about Rails and CMS development."],
  ["CMS Field Day", "Amsterdam, Netherlands", Time.utc(2026, 6, 20, 10), Time.utc(2026, 6, 20, 16),
    "Hands-on workshops on structuring content with Elements and Ingredients."],
  ["Alchemy 8 Release Party", "Online", Time.utc(2026, 9, 30, 17), Time.utc(2026, 9, 30, 19),
    "Celebrating the Alchemy 8 release with a live walkthrough of what's new."],
  ["Content Modeling Workshop", "Hamburg, Germany", Time.utc(2026, 10, 22, 9, 30), Time.utc(2026, 10, 22, 13),
    "Design custom modules and ingredients for real editorial workflows."],
  ["Year-end Community Call", "Online", Time.utc(2026, 12, 10, 16), Time.utc(2026, 12, 10, 17),
    "Roadmap, thanks and open Q&A to close out the year."]
]
locations = {}
events = events_data.map do |name, location_name, starts_at, ends_at, description|
  location = locations[location_name] ||= Location.create!(name: location_name)
  Event.create!(name:, location:, starts_at:, ends_at:, description:)
end

Alchemy::Element.where(name: "concept_intro")
  .joins(page_version: :page)
  .where(alchemy_pages: {urlname: "events"})
  .find_each do |element|
    element.ingredient_by_role(:eyebrow)&.update!(value: "Advanced")
    element.ingredient_by_role(:headline)&.update!(value: "Custom modules & Ingredients")
    element.ingredient_by_role(:lead)&.update!(value:
      "<p>Alchemy can be extended with your own admin <strong>modules</strong> and <strong>Ingredient</strong> types. This page manages a custom Event model in the admin and surfaces it two ways below.</p>")
  end

# Two overviews on the page: an upcoming timeline and a full calendar
overviews = Alchemy::Element.where(name: "events_overview")
  .joins(page_version: :page)
  .where(alchemy_pages: {urlname: "events"})
  .order(:position).to_a
if (timeline = overviews[0])
  timeline.ingredient_by_role(:headline)&.update!(value: "Upcoming events")
  timeline.ingredient_by_role(:timeframe)&.update!(value: "upcoming")
  timeline.ingredient_by_role(:display)&.update!(value: "timeline")
end
if (calendar = overviews[1])
  calendar.ingredient_by_role(:headline)&.update!(value: "Full calendar")
  calendar.ingredient_by_role(:timeframe)&.update!(value: "all")
  calendar.ingredient_by_role(:display)&.update!(value: "calendar")
end

# Feature one event per teaser (the custom Event ingredient references a record)
featured = events.select { |event| event.ends_at >= Time.current }.presence || events
Alchemy::Element.where(name: "event_teaser")
  .joins(page_version: :page)
  .where(alchemy_pages: {urlname: "events"})
  .order(:position).each_with_index do |teaser, index|
    teaser.ingredient_by_role(:event)&.update!(related_object: featured[index % featured.size])
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

# Main navigation is built from the root page and its children
YAML.load_file("./db/seeds/alchemy/pages.yml", permitted_classes: [Date])
  .reject { |page| page["layoutpage"] }
  .each do |page|
    parent_page = Alchemy::Page.find_by!(name: page["name"], page_layout: page["page_layout"])
    parent = Alchemy::Node.create!(
      name: "Main Navigation",
      menu_type: "main_navigation",
      site: parent_page.site,
      language: parent_page.language
    )
    puts "== Created menu: #{parent.name}"

    page["children"]&.each do |child|
      child_page = Alchemy::Page.find_by!(name: child["name"], page_layout: child["page_layout"])
      Alchemy::Node.create!(
        parent: parent,
        page: child_page,
        site: parent.site,
        language: parent.language
      )
      puts "== Created menu entry: #{child_page.name}"
    end
  end

# Footer navigation menu: sections of links to Alchemy resources. It is editable
# under Menus in the admin and referenced by the footer element's Node ingredient.
footer_sections = [
  ["Resources", [
    ["Homepage", "https://alchemy-cms.com"],
    ["Guides", "https://guides.alchemy-cms.com"],
    ["Source code", "https://github.com/AlchemyCMS/alchemy_cms"],
    ["Live demo", "https://demo.alchemy-cms.com"]
  ]],
  ["Community", [
    ["Slack", "https://alchemy-cms.slack.com"],
    ["Mastodon", "https://ruby.social/@alchemy_cms"],
    ["Bluesky", "https://bsky.app/profile/alchemy-cms.com"],
    ["GitHub", "https://github.com/AlchemyCMS"]
  ]]
]
language = Alchemy::Language.default
footer_menu = Alchemy::Node.create!(
  name: "Footer Navigation", menu_type: "footer_navigation", site: language.site, language: language
)
footer_sections.each do |section_name, links|
  section = Alchemy::Node.create!(
    parent: footer_menu, name: section_name, site: language.site, language: language
  )
  links.each do |link_name, url|
    Alchemy::Node.create!(
      parent: section, name: link_name, url: url, external: true, site: language.site, language: language
    )
  end
end
puts "== Created footer navigation"

# Point the footer element's Node ingredient at the footer navigation menu
Alchemy::Page.find_by(page_layout: "footer")&.draft_version&.elements
  &.find_by(name: "footer_nav")&.ingredient_by_role(:menu)&.update!(related_object: footer_menu)

# Ingredients catalog: fill one ingredient of each type on the Ingredients page
catalog = Alchemy::Element.where(name: "ingredient_catalog")
  .joins(page_version: :page)
  .where(alchemy_pages: {urlname: "ingredients"}).first
if catalog
  elements_page = Alchemy::Page.find_by(urlname: "elements")
  main_nav_node = Alchemy::Node.roots.find_by(menu_type: "main_navigation")
  catalog_photo = Alchemy::Picture.find_by(name: "photo-02") || Alchemy::Picture.where("name LIKE ?", "photo-%").first
  upcoming_event = Event.upcoming.first
  # file_name is derived from the Active Storage blob (not a queryable column)
  attachments = Alchemy::Attachment.all.to_a
  audio_att = attachments.find { |a| a.file_name.to_s.start_with?("sample-audio") }
  video_att = attachments.find { |a| a.file_name.to_s.start_with?("sample-video") }
  file_att = attachments.find { |a| a.file_name.to_s.start_with?("sample-document") }

  catalog.ingredient_by_role(:text)&.update!(value: "A single line of text.")
  catalog.ingredient_by_role(:headline)&.update!(value: "I am a Headline", level: 3, size: 4)
  catalog.ingredient_by_role(:richtext)&.update!(value: '<p>Rich text with <strong>bold</strong> and a <a href="/elements">link</a>.</p>')
  catalog.ingredient_by_role(:picture)&.update!(related_object: catalog_photo) if catalog_photo
  catalog.ingredient_by_role(:link)&.update!(value: "/elements")
  catalog.ingredient_by_role(:page)&.update!(related_object: elements_page) if elements_page
  catalog.ingredient_by_role(:node)&.update!(related_object: main_nav_node) if main_nav_node
  catalog.ingredient_by_role(:select)&.update!(value: "first")
  catalog.ingredient_by_role(:color)&.update!(value: "#884cbe")
  catalog.ingredient_by_role(:datetime)&.update!(value: Time.utc(2026, 6, 15, 14, 30))
  catalog.ingredient_by_role(:boolean)&.update!(value: true)
  catalog.ingredient_by_role(:number)&.update!(value: 42)
  catalog.ingredient_by_role(:html)&.update!(value: "<mark>Highlighted with raw HTML</mark>")
  catalog.ingredient_by_role(:audio)&.update!(related_object: audio_att, controls: true) if audio_att
  catalog.ingredient_by_role(:video)&.update!(related_object: video_att, controls: true) if video_att
  catalog.ingredient_by_role(:file)&.update!(related_object: file_att, link_text: "Download the sample document") if file_att
  catalog.ingredient_by_role(:event)&.update!(related_object: upcoming_event) if upcoming_event
end

Alchemy::Element.where(name: "concept_intro")
  .joins(page_version: :page)
  .where(alchemy_pages: {urlname: "ingredients"})
  .find_each do |element|
    element.ingredient_by_role(:eyebrow)&.update!(value: "Core concept")
    element.ingredient_by_role(:headline)&.update!(value: "Ingredients")
    element.ingredient_by_role(:lead)&.update!(value:
      "<p><strong>Ingredients</strong> are the typed fields inside an Element. Each one stores a specific kind of content. Here is one of every built-in type — plus a custom one.</p>")
  end

puts "\nPublish Pages"
puts "-------------"
Alchemy::Page.all.each do |page|
  Alchemy::PublishPageJob.perform_now(page.id, public_on: Time.current)
  puts "== Published Page: #{page.name}"
end

puts "\nSeeding finished 🎉"
