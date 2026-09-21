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
  ["Pages & Page Layouts", "<p>Each page follows a layout that decides which blocks it can hold. Freedom where you want it, guardrails where you don’t.</p>", "concept-pages", "/pages"],
  ["Elements", "<p>The building blocks. Define one once, reuse it on any page, render it with your own template.</p>", "concept-elements", "/elements"],
  ["Ingredients", "<p>The fields inside a block: text, rich text, pictures, links, dates. Each knows what it is, so editors get the right input for it.</p>", "concept-ingredients", "/ingredients"],
].each_with_index do |(title, description, illustration_name, link_path), index|
  card = Alchemy::Element.where(name: "concept_card").order(:position)[index]
  next unless card

  card.ingredient_by_role(:title)&.update(value: title)
  card.ingredient_by_role(:description)&.update(value: description)
  card.ingredient_by_role(:link)&.update!(value: "Learn more", link: link_path)
  illustration = Alchemy::Picture.find_by(name: illustration_name)
  card.ingredient_by_role(:illustration)&.update!(related_object: illustration) if illustration
end

# Home: the capability grid, and the "how this page works" band. Every claim in
# the grid is backed by a real Alchemy feature, not by this demo.
home_draft = Alchemy::Page.find_by(page_layout: "home")&.draft_version
if home_draft
  feature_list = home_draft.elements.find_by(name: "feature_list")
  if feature_list
    feature_list.ingredient_by_role(:lead)&.update!(value:
      "<p>Alchemy ships with what a real site needs, so you are not gluing it together yourself.</p>")

    [
      ["photo", "Media library",
        "<p>Upload once, use anywhere. Crop an image differently for each place it appears without altering the original, and let the browser download only the size it needs.</p>", nil],
      ["documents", "Draft and publish",
        "<p>Every page has a draft you work on and a published version visitors see. Nothing goes live until you say so.</p>", nil],
      ["clock", "Publish on a schedule",
        "<p>Give a page a go-live date and an end date. Embargoed announcements and time-limited campaigns handle themselves.</p>", nil],
      ["lock", "Roles and restricted pages",
        "<p>Members-only sections, internal pages, and editors who can only reach what they should.</p>", nil],
      ["magnifier", "Built for search engines",
        "<p>Readable URLs, per-page titles and descriptions, robots settings, an automatic sitemap, and redirects that keep old links working when a page moves.</p>", nil],
      ["globe", "Languages and sites",
        "<p>Run several languages, several domains, or several separate sites from one installation.</p>", nil],
      ["menu", "Menus and shared content",
        "<p>Build navigation in the admin and reuse content across every page, the way this site’s own footer does.</p>", nil],
      ["code", "JSON API",
        "<p>Read your pages and elements as JSON — for a mobile app, a search index, or a separate frontend.</p>",
        ["See /api/pages", "/api/pages"]]
    ].each do |icon, title, description, link|
      item = Alchemy::Element.create!(
        name: "feature_item", page_version: home_draft,
        parent_element: feature_list, autogenerate_nested_elements: false
      )
      item.ingredient_by_role(:icon)&.update!(value: icon)
      item.ingredient_by_role(:title)&.update!(value: title)
      item.ingredient_by_role(:description)&.update!(value: description)
      item.ingredient_by_role(:link)&.update!(value: link[0], link: link[1]) if link
    end
  end

  band = home_draft.elements.not_nested.find_by(name: "image_text")
  if band
    band.ingredient_by_role(:headline)&.update!(value: "Curious how this page works?")
    band.ingredient_by_role(:text)&.update!(value:
      "<p>This whole site is an Alchemy site — none of it is hardcoded. On any block, choose “How this block is built” to see its real definition, then jump straight into the admin and change it.</p>")
    illustration = Alchemy::Picture.find_by(name: "concept-inspect")
    band.ingredient_by_role(:image)&.update!(related_object: illustration) if illustration

    # image_text brings no width or spacing of its own, so give it a Section to
    # sit in, the way the tour pages do.
    position = band.position
    section = Alchemy::Element.create!(
      name: "section", page_version: home_draft, autogenerate_nested_elements: false
    )
    section.ingredient_by_role(:background)&.update!(value: "bg-surface-faint")
    section.ingredient_by_role(:spacing)&.update!(value: "py-16")
    band.update!(parent_element_id: section.id)
    section.insert_at(position)
  end
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
      "<p>You can define any Element as <strong>nestable</strong>, so it holds child Elements. The slider and gallery below both nest gallery_image Elements, each a Picture served responsively; the same children are shown three ways: an autoplaying slider, a grid and a masonry.</p>" \
      "<p>Alchemy provides the nesting and the typed Ingredients. The three layouts are this demo's own frontend code — view partials, plus an <strong>&lt;alchemy-slider&gt;</strong> custom element for the carousel — not built-in widgets. Your application renders nested Elements however it likes.</p>")
  end

# Galleries page: three nestable layouts. The slider is its own element (driven
# by the <alchemy-slider> custom element); the gallery renders as a grid or a
# masonry via its appearance Select.
slider_element = Alchemy::Element.joins(page_version: :page)
  .where(name: "slider", alchemy_pages: {urlname: "galleries"}).first
if slider_element
  slider_element.ingredient_by_role(:headline)&.update!(value: "Image slider")
  slider_element.ingredient_by_role(:autoplay)&.update!(value: true)
  slider_element.ingredient_by_role(:duration)&.update!(value: 4000)
  slider_element.ingredient_by_role(:transition)&.update!(value: 500)
  slider_element.ingredient_by_role(:per_slide)&.update!(value: "1")
end

galleries = Alchemy::Element.where(name: "image_gallery")
  .joins(page_version: :page)
  .where(alchemy_pages: {urlname: "galleries"})
  .order(:position).to_a
if (grid = galleries[0])
  grid.ingredient_by_role(:appearance)&.update!(value: "grid")
  grid.ingredient_by_role(:headline)&.update!(value: "Picture gallery")
end
if (masonry = galleries[1])
  masonry.ingredient_by_role(:appearance)&.update!(value: "masonry")
  masonry.ingredient_by_role(:headline)&.update!(value: "Masonry gallery")
end

# Blog: distinct article headers (+ a photo each), a body per article, and the
# overview intro. Without a body, every article falls back to the same
# :prose_text default.
blog_photos = Alchemy::Picture.where("name LIKE ?", "photo-%").order(:id).to_a
[
  ["blog/composing-content-with-elements", "Composing content with Elements", Date.new(2026, 6, 2),
    "<p>How a page is assembled from reusable Elements, each made of typed Ingredients.</p>",
    "Composing a page from Elements",
    "<p>A Page Layout lists which Elements a page may contain. This article page allows exactly two: a <strong>post_header</strong> and a <strong>prose</strong> block — the one you are reading now.</p>" \
    "<p>Each Element is defined once in <strong>config/alchemy/elements.yml</strong> and can be reused on any page. Editors then:</p>" \
    "<ul><li>add and remove Elements,</li><li>sort and nest them,</li><li>fill in their typed Ingredients.</li></ul>" \
    "<p>None of this layout is hard-coded into the page. The frontend renders every Element through its own view partial, so a prose block reads the same here as it does anywhere else on the site.</p>"],
  ["blog/cropping-and-responsive-images", "Cropping and responsive images", Date.new(2026, 6, 9),
    "<p>Using Picture ingredients with cropping, srcset and sizes for sharp, fast images.</p>",
    "One file, many renderings",
    "<p>A <strong>Picture</strong> ingredient does not hold a copy of an image. It references a single file in the picture library, and every place that uses it asks for its own rendering.</p>" \
    "<p>The header image above is cropped to a fixed 16:9 ratio. The crop lives on the ingredient rather than on the file, so the same picture can be a wide banner here and a taller, differently cropped tile in a gallery without ever being re-uploaded. Editors set it in the admin with a visual cropper.</p>" \
    "<p>Responsive delivery is declared next to it in the element definition: a <strong>srcset</strong> of several widths — 400, 800 and 1200 pixels wide for this header — and a <strong>sizes</strong> hint describing how wide the image will really be rendered. The browser downloads only the variant it picks.</p>" \
    "<p>Alchemy processes each variant on demand and caches the result, so adding another width to the list costs nothing up front. Open “How this block is built” on the header above to see the exact settings.</p>"],
  ["blog/nesting-elements-in-a-gallery", "Nesting elements in a gallery", Date.new(2026, 6, 16),
    "<p>Nestable Elements let editors build galleries and other repeating structures.</p>",
    "Parents, children and the admin",
    "<p>Any Element can be declared <strong>nestable</strong>, which lets it contain child Elements of the types it names. A gallery is nothing more than that: an <strong>image_gallery</strong> parent whose children are <strong>gallery_image</strong> Elements.</p>" \
    "<p>The parent carries whatever applies to the whole group — a headline, and an <em>appearance</em> Select that switches between a grid and a masonry layout. Each child carries one Picture and one caption. Editors add, remove and reorder children by dragging them in the admin, and the frontend simply renders whichever children it finds.</p>" \
    "<p>Nesting is not just for galleries. Every content band on the tour pages is a <strong>section</strong> Element nesting the blocks inside it, which is how one page mixes backgrounds and spacing without a separate page layout per variation.</p>" \
    "<p>See all three layouts on the <a href=\"/galleries\">Galleries page</a>.</p>"],
].each_with_index do |(urlname, title, date, intro, body_headline, body_text), index|
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

  Alchemy::Element.where(name: "prose")
    .joins(page_version: :page)
    .where(alchemy_pages: { urlname: urlname })
    .find_each do |body|
      body.ingredient_by_role(:headline)&.update!(value: body_headline)
      body.ingredient_by_role(:text)&.update!(value: body_text)
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

# Ingredients tour: build the four groups on the Ingredients page. A single
# ingredient_group element is reused for each; the grouping — heading, intro and
# which ingredient-row elements it nests — lives here in the seed, not in the
# element definitions. Each row is a *_ingredient element holding one "value".
ingredients_draft = Alchemy::Page.find_by(urlname: "ingredients")&.draft_version
if ingredients_draft
  catalog_photo = Alchemy::Picture.find_by(name: "photo-02") || Alchemy::Picture.where("name LIKE ?", "photo-%").first
  # file_name is derived from the Active Storage blob (not a queryable column)
  attachments = Alchemy::Attachment.all.to_a
  audio_att = attachments.find { |a| a.file_name.to_s.start_with?("sample-audio") }
  video_att = attachments.find { |a| a.file_name.to_s.start_with?("sample-video") }
  file_att = attachments.find { |a| a.file_name.to_s.start_with?("sample-document") }
  elements_page = Alchemy::Page.find_by(urlname: "elements")
  main_nav_node = Alchemy::Node.roots.find_by(menu_type: "main_navigation")
  upcoming_event = Event.upcoming.first

  ingredient_groups = [
    ["Content ingredients",
      "<p>These store their value directly in the ingredient. They cover most day-to-day editing — text, formatting, choices and simple values.</p>",
      [
        ["text_ingredient", {value: "A single line of text."}],
        ["headline_ingredient", {value: "I am a Headline", level: 3, size: 4}],
        ["richtext_ingredient", {value: '<p>Rich text with <strong>bold</strong> and a <a href="/elements">link</a>.</p>'}],
        ["select_ingredient", {value: "first"}],
        ["color_ingredient", {value: "#884cbe"}],
        ["datetime_ingredient", {value: Time.utc(2026, 6, 15, 14, 30)}],
        ["boolean_ingredient", {value: true}],
        ["number_ingredient", {value: 42}],
        ["html_ingredient", {value: "<mark>Highlighted with raw HTML</mark>"}]
      ]],
    ["Media ingredients",
      "<p>These reference an asset from the library — a picture, or an uploaded audio, video or file — rather than storing the media itself.</p>",
      [
        # The row is always created so the type renders; the value is only set
        # when the asset exists (pictures/attachments are not seeded in tests).
        ["picture_ingredient", catalog_photo && {related_object: catalog_photo}],
        ["audio_ingredient", audio_att && {related_object: audio_att, controls: true}],
        ["video_ingredient", video_att && {related_object: video_att, controls: true}],
        ["file_ingredient", file_att && {related_object: file_att, link_text: "Download the sample document"}]
      ]],
    ["Reference ingredients",
      "<p>These point at something else in the system: a link target, another page, or a menu node.</p>",
      [
        ["link_ingredient", {value: "/elements"}],
        ["page_ingredient", elements_page && {related_object: elements_page}],
        ["node_ingredient", main_nav_node && {related_object: main_nav_node}]
      ]],
    ["Custom ingredients",
      "<p>Alchemy's built-in types cover most needs, but you can define your own. This Event ingredient is a custom type that references a record from our Event model, managed in the Events admin module.</p>",
      [
        ["event_ingredient", upcoming_event && {related_object: upcoming_event}]
      ]]
  ]

  ingredient_groups.each do |headline, lead, rows|
    group = Alchemy::Element.create!(
      name: "ingredient_group", page_version: ingredients_draft, autogenerate_nested_elements: false
    )
    group.ingredient_by_role(:headline)&.update!(value: headline)
    group.ingredient_by_role(:lead)&.update!(value: lead)
    rows.each do |row_name, attrs|
      row = Alchemy::Element.create!(
        name: row_name, page_version: ingredients_draft, parent_element: group, autogenerate_nested_elements: false
      )
      row.ingredient_by_role(:value)&.update!(**attrs) if attrs
    end
  end
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

# Elements page: demonstrate time-based element visibility with a scheduled note
scheduled_note = Alchemy::Element.joins(page_version: :page)
  .where(name: "scheduled_note", alchemy_pages: {urlname: "elements"}).first
if scheduled_note
  scheduled_note.ingredient_by_role(:headline)&.update!(value: "Scheduled elements", level: 2, size: 3)
  scheduled_note.ingredient_by_role(:text)&.update!(value:
    "<p>Every Element can be given its own <strong>start and end date</strong>, so content appears and disappears on schedule — a launch banner, a seasonal promo. This very note is scheduled (visible 2026–2030); after its end date it would simply drop off the page.</p>")
  sched_illustration = Alchemy::Picture.find_by(name: "concept-schedule")
  scheduled_note.ingredient_by_role(:illustration)&.update!(related_object: sched_illustration) if sched_illustration
  scheduled_note.update!(public_on: Time.utc(2026, 1, 1), public_until: Time.utc(2030, 1, 1))
end

# Pages concept page: page layouts, the draft/publish workflow, scheduling and access control
pages_scope = Alchemy::Element.joins(page_version: :page).where(alchemy_pages: {urlname: "pages"})
pages_scope.where(name: "concept_intro").find_each do |el|
  el.ingredient_by_role(:eyebrow)&.update!(value: "Core concept")
  el.ingredient_by_role(:headline)&.update!(value: "Pages & Page Layouts")
  el.ingredient_by_role(:lead)&.update!(value:
    "<p>Every Page has a <strong>Page Layout</strong> that decides which Elements it may contain. Pages are versioned, can be scheduled, and can be restricted to certain roles.</p>")
end
pages_scope.where(name: "prose").find_each do |el|
  el.ingredient_by_role(:headline)&.update!(value: "Draft and publish")
  el.ingredient_by_role(:text)&.update!(value:
    "<p>Every Page keeps two versions: a <strong>draft</strong> you edit and a <strong>public</strong> version visitors see. Publishing copies the draft over the public version, so work in progress never leaks — and you can preview the draft in the admin any time.</p><ul><li>Edit the draft freely.</li><li>Preview it privately.</li><li>Publish when it's ready.</li></ul>")
end
pages_callouts = pages_scope.where(name: "callout").order(:position).to_a
if (c = pages_callouts[0])
  c.ingredient_by_role(:variant)&.update!(value: "info")
  c.ingredient_by_role(:text)&.update!(value:
    "<p><strong>Scheduled publishing.</strong> Give a Page a <strong>go-live date</strong> to publish it automatically at a future time, and an <strong>end date</strong> to retire it — ideal for embargoed news or time-limited campaigns.</p>")
end
if (c = pages_callouts[1])
  c.ingredient_by_role(:variant)&.update!(value: "tip")
  c.ingredient_by_role(:text)&.update!(value:
    "<p><strong>Restricted pages.</strong> Mark a Page as <em>restricted</em> and choose its <em>permitted roles</em>, so only signed-in users with those roles can see it — perfect for members-only or internal content.</p>")
end
pages_scope.where(name: "code_sample").find_each do |el|
  el.ingredient_by_role(:caption)&.update!(value: "config/alchemy/page_layouts.yml")
  el.ingredient_by_role(:language)&.update!(value: "yaml")
  el.ingredient_by_role(:code)&.update!(value: <<~YAML)
    - name: article
      cache: false
      elements: [post_header, prose]

    # A Page can also be scheduled and access-controlled:
    #   public_on:       2026-09-01 09:00   # goes live
    #   public_until:    2026-12-31 23:59   # retires automatically
    #   restricted:      true               # signed-in visitors only
    #   permitted_roles: [member]           # ...with one of these roles
  YAML
end

# Wrap each tour page's flat content into Section elements with alternating
# backgrounds, nesting the content so pages read as banded sections rather than
# one long column. Runs after content is set and before publishing; specialized
# top-level elements (catalog, overviews, forms, galleries) stay as they are.
SECTION_CONTENT = %w[
  concept_intro prose image_text callout scheduled_note code_sample
  ingredient_group image_gallery slider
].freeze
Alchemy::Page.where.not(page_layout: %w[home footer]).find_each do |page|
  draft = page.draft_version
  next unless draft

  band = 0
  ordered = draft.elements.not_nested.order(:position).to_a.map do |element|
    next element unless SECTION_CONTENT.include?(element.name)

    section = Alchemy::Element.create!(
      name: "section", page_version: draft, autogenerate_nested_elements: false
    )
    section.ingredient_by_role(:background)&.update!(value: band.even? ? "bg-white" : "bg-surface-faint")
    section.ingredient_by_role(:spacing)&.update!(value: "py-16")
    band += 1
    element.update!(parent_element_id: section.id)
    section
  end
  # insert_at rewrites the top-level order so sections sit where their content
  # used to, keeping specialized elements interleaved in their original places.
  ordered.each_with_index { |element, index| element.insert_at(index + 1) }
end

puts "\nPublish Pages"
puts "-------------"
Alchemy::Page.all.each do |page|
  Alchemy::PublishPageJob.perform_now(page.id, public_on: Time.current)
  puts "== Published Page: #{page.name}"
end

puts "\nSeeding finished 🎉"
