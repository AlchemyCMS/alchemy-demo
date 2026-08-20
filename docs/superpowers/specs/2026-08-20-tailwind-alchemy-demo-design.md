# Design: Drop zurb-foundation, rebuild the demo as a self-explaining Alchemy tour

Date: 2026-08-20

## Overview

The Alchemy demo currently styles its public frontend with zurb-foundation 4
(jQuery-era, unmaintained, and needing a boot-time monkey-patch to survive the
Rails 8.1 upgrade). This project replaces that toolchain with Tailwind CSS and
rebuilds the demo content into an **interactive, guided tour that teaches how
Alchemy works** — where every page is a lesson about the very Alchemy feature
that renders it.

The guiding concept: **the page explains itself.** Each content element carries
a native `<details>` disclosure ("🔍 How this block is built") that expands to
show the element's name, its ingredient roles and types, and any nested element
names — introspected from the live element, so it is always accurate and never
hardcoded. A visitor reads a page, then peeks under any block to see the Alchemy
definition behind it.

### Goals

- Replace zurb-foundation and jQuery with Tailwind CSS across the whole
  frontend. (The dependency removal and toolchain swap already shipped in
  PR #338; what remains is restyling the templates and rebuilding the content —
  see the merge & deployment constraint below.)
- Rebuild the demo as a curriculum that demonstrates Alchemy's core building
  blocks and several advanced integrations, using real Alchemy features to
  demonstrate themselves.
- Keep the app Node-free (standalone Tailwind CLI) and idiomatic for Rails 8.1 /
  Alchemy 8.3.
- Prefer native HTML/CSS for interactivity; treat JavaScript as a last resort.

### Non-goals (YAGNI)

- No Turbo Frames or Turbo Streams — we use **Turbo Drive only** (the
  Turbolinks-style navigation replacement); no partial-page or SPA behavior.
- No real email delivery from the contact form (see Contact component).
- No pixel-for-pixel reproduction of Tailwind UI examples; we adapt them.
- No redesign of the Alchemy admin — admin keeps its own assets and styling.

## Navigation: Turbo Drive

`turbo-rails` (already in the bundle transitively via the Alchemy admin) is added
as an explicit host-app gem and pinned in the importmap. The public entrypoint
(`app/javascript/application.js`) imports Turbo and calls `Turbo.start()` — we
use **Turbo Drive only** for faster, Turbolinks-style navigation; Frames and
Streams are intentionally unused. Implications:

- `data-turbo-track: "reload"` is set on the Tailwind stylesheet and JS tags so
  an asset-digest change forces a full reload.
- The contact `<form>` is opted out with `data-turbo="false"`. Turbo Drive
  expects form responses to redirect or return 422, but Alchemy's
  `MessagesController#create` re-renders with **status 200** on validation
  errors (which Turbo will not render); a normal full submit keeps inline errors
  working. Turbo Drive still governs all page navigation.

## Interactivity policy: native first

Client-side behavior uses native HTML/CSS wherever possible:

- Disclosures / accordions / the "how it's built" reveal → `<details>/<summary>`.
- Galleries / carousels → CSS scroll-snap.
- Mobile navigation → `<details>`-based disclosure menu.

The design targets **zero custom JavaScript**, so Stimulus is intentionally not
installed. Import maps and Turbo are present. The single foreseen exception is a
"copy" button on code samples; if it is wanted and native selection is deemed
insufficient, we add `stimulus-rails` plus one `clipboard_controller` at that
point. Any decision to add JavaScript must be justified against this policy.

## Delivery phases (Approach A — sequenced, each its own PR)

1. **Phase 1 — Toolchain swap (DONE, PR #338, branch `chore/tailwind-toolchain`).**
   Removed `zurb-foundation`, `jquery-rails`, `sassc-rails`, `uglifier`,
   `foundation_and_overrides.scss`, the sprockets `application.css`/`.js`, and
   the Rails-8.1 Foundation boot monkey-patch. Added `tailwindcss-rails` (v4,
   standalone CLI — no Node) and `importmap-rails`. With Foundation's SCSS gone,
   nothing needs Sprockets, so the pipeline moves to **Propshaft** (the Rails 8
   default): Propshaft serves the Tailwind build, the importmap JavaScript, and
   Alchemy's prebuilt admin assets, so `app/assets/config/manifest.js` and the
   Sprockets-only config are removed. Reconciled the layout (Tailwind stylesheet
   + `javascript_importmap_tags`) and CI (`test.yml` builds the gitignored
   Tailwind artifact before the suite). Adds Turbo Drive (`turbo-rails` +
   `Turbo.start()`, see Navigation). Stimulus is not installed (native-first).
   Existing templates still carry now-inert Foundation classes and render
   unstyled until Phase 2.

2. **Phase 2 — Design system + elements/page-layouts redesign.** The Tailwind
   theme, the new element and page-layout definitions, their Tailwind markup
   partials, the shared self-explaining `<details>` partial, the custom `Event`
   ingredient, and the Events admin module. Templates render styled with
   placeholder/default content.

3. **Phase 3 — Content & seeds.** The tour page tree (`pages.yml`), element
   default content (the curriculum copy), picture assignments, menus, the
   contact-form mailer config, and the Events/Locations seed data. This is the
   phase that turns styled scaffolding into the finished guided tour.

Each phase keeps the `published_pages_test` green and ships as an independent,
reviewable PR.

### Merge & deployment constraint

`main` auto-deploys to the live demo, and CI passes even when the site is
unstyled (pages still render 200). Therefore **PR #338 must not be merged to
`main` on its own** — after Phase 1 the templates still carry now-inert
Foundation classes, so merging it alone would deploy a broken-looking demo. The
toolchain change may only reach `main` together with the Phase 2 restyle.

To keep per-phase PRs reviewable without ever leaving `main` in a broken state,
the phases land on the long-lived integration branch `tailwind-migration`
(branched from `main`). This is the chosen strategy:

- PR #338 (Phase 1) is retargeted to merge into `tailwind-migration`, not `main`
  (done).
- Phase 2 and Phase 3 PRs also target `tailwind-migration` and stack on top.
- Only once the demo is fully styled and content-complete is `tailwind-migration`
  merged into `main` — a single, never-broken deploy.

## Design system (Tailwind theme)

Direction: **"Alchemy-lab"** — a deep violet/indigo base with a bright "potion"
accent on clean neutrals; darker violet surfaces for hero and footer.

Defined via Tailwind v4 CSS-first config in `app/assets/tailwind/application.css`
using `@theme`:

- `--color-brand-*` — violet/indigo primary scale (buttons, links, headings
  accents).
- `--color-potion-*` — emerald/lime accent scale (highlights, the "reveal"
  affordance, active states). Nods to Alchemy's green heritage.
- Neutral surfaces from Tailwind's `slate`/`zinc`.
- Dark surfaces: `brand-950`-tinted backgrounds for hero and footer.
- Typography: a display face for headings and a readable sans for body (loaded
  as web fonts or system stack — exact choice finalized in Phase 2; keep it to
  one display + one body face).

Tailwind UI (free/Plus) examples adapted per component (marketing/application
categories): Hero, Feature sections, CTA sections, FAQ, Blog sections, Contact
form, Header/Footer navigation. These are references, not verbatim copies.

## Page layouts (`config/alchemy/page_layouts.yml`)

- `home` (unique) — landing: hero, concept grid, CTA.
- `concept` — the workhorse tour page; allows most content elements.
- `blog` — blog overview; teases child pages (posts) in its partial.
- `blog_post` — a single post.
- `contact` — must match `Alchemy.config.mailer.page_layout_name`; `cache: false`.
- `thanks` (unique) — contact success page.
- `events` — the custom-module / custom-ingredient showcase page.
- `footer` (layoutpage) — global footer content.

## Elements (`config/alchemy/elements.yml`)

Each element is chosen to demonstrate an ingredient type or structural feature.

| Element | Ingredients (types demonstrated) | Teaches / feature |
|---|---|---|
| `hero` (unique) | headline (Text), subheadline (Text), cta (Link) | Link ingredient |
| `concept_intro` | eyebrow (Text), headline (Text), lead (Richtext) | Richtext |
| `text_block` | headline (Text), text (Richtext) | basics |
| `image_text` | image (Picture), headline (Text), text (Richtext), position (Select) | Picture + Select |
| `concept_grid` → nests `concept_card` | headline (Text) | nestable + feature grid |
| `concept_card` (compact) | icon (Select), title (Text), description (Richtext), link (Link) | compact/nested |
| `code_sample` | label (Text), language (Select), code (Text) | "how it's built" content |
| `callout` | variant (Select: info/tip/warning), text (Richtext) | Select |
| `gallery` → nests `gallery_image` | headline (Text) | nestable + CSS scroll-snap |
| `gallery_image` (compact) | image (Picture), caption (Text) | — |
| `accordion` → nests `accordion_item` | headline (Text) | nestable + native `<details>` |
| `accordion_item` (compact) | question (Text), answer (Richtext) | — |
| `post_header` (unique) | headline (Text), published_at (Datetime), author (Text), image (Picture), intro (Richtext) | Datetime; drives blog teasers |
| `contactform` (unique) | mail_from (Text), mail_to (Text), subject (Text), success_page (Page) | Page ingredient + Messages |
| `event_teaser` | headline (Text), event (Event — custom ingredient) | custom ingredient |
| `cta` | headline (Text), text (Richtext), button (Link) | — |
| `footer_note` (unique) | body (Richtext) | footer |
| `social_links` → nests `social_link` | headline (Text) | nestable footer |
| `social_link` (compact) | label (Text), url (Link) | — |

### The self-explaining `<details>` partial

A shared partial (e.g. `app/views/alchemy/elements/_reveal.html.erb`) takes an
`element` and renders a native `<details>` containing:

- `element.name`
- each ingredient's `role → type` (from `element.ingredients`, whose members
  respond to `.role` and `.type`)
- nested element names where applicable

Because it reads the live element, the shown definition is always accurate.
Every content element partial renders it (styled as a subtle "reveal"
affordance in the potion accent).

## Component: Blog (page tree + teasing children)

A `blog` overview page whose **child pages** are `blog_post` pages, teased on the
overview. Demonstrates the page tree (parent/children) and reading content from
other pages. Verified Alchemy 8.3 APIs:

- Children (published content pages): `@page.children.published.contentpages`.
  (`@page` is available in page-layout partials. `Alchemy::Page` uses
  `acts_as_nested_set`, providing `children`; `published` is version-based in
  8.3, and there is **no** `visible`/`public` scope — use `published`.)
- Per-post teaser fields: `post.elements.named("post_header").first&.value_for(:headline)`
  / `&.value_for(:intro)`; image via `&.ingredient_by_role(:image)`.
  (`value_for` / `ingredient_by_role` are **Element** methods, not Page methods.)
- Link to a post: `alchemy.show_page_path(post)`.

## Component: Contact form (built-in `Alchemy::Messages`)

Demonstrates Alchemy's built-in messages feature. Verified facts:

- A page with `page_layout == Alchemy.config.mailer.page_layout_name` must exist
  (we use `page_layout_name = "contact"`), or `MessagesController#get_page`
  raises.
- The `contactform` element (unique) has `mail_from`/`mail_to`/`subject` (Text)
  and `success_page` (Page) ingredients. The controller reads these via
  `@element.value_for(:mail_to)` etc., falling back to `Alchemy.config.mailer`.
- We author the form partial ourselves (the gem ships only a non-functional
  stub). Use `form_with model: @message, url: alchemy.messages_path` with one
  input per configured field **plus a required hidden
  `f.hidden_field :contact_form_id, value: element.id`** — without it, `create`
  raises `ActiveRecord::RecordNotFound`.
- `@message` is available because `new`/`create` render `alchemy/pages/show`.
  On invalid submit the page re-renders with validation errors inline; on valid
  submit it redirects (flash notice `contactform.messages.success`) to the
  success page.

Decisions:

- **Fields:** `name`, `email`, `message` (simple 3-field form). Configure
  `Alchemy.config.mailer.fields = %w[name email message]` and
  `validate_fields = %w[email message]` (email also format-validated because the
  field name matches `/email/`). Because the `Message` model builds its
  attributes/validations from config at load time, and the gem's default mailer
  text template references the default field set, we ship a **custom mailer text
  template** at `app/views/alchemy/messages_mailer/contact_form_mail.text.erb`
  referencing `name`/`email`/`message`.
- **Delivery:** do **not** send real mail. Configure ActionMailer delivery so
  the form validates, redirects to a Thank-you page, and shows the success flash
  without sending (e.g. `:test` delivery). A teaching note on the page explains
  you would wire SMTP in production.
- **Config location:** `config/initializers/alchemy.rb` via
  `config.mailer.tap do |mailer| ... end` (the 8.3 typed-config idiom).
- **Success page:** a dedicated "Thank you" page (`thanks` layout); the
  `contactform` element's `success_page` ingredient points at it (set in seeds).
- **Flash:** the application layout currently renders no flash — add flash
  rendering (needed for the success notice).
- **Turbo:** the `<form>` carries `data-turbo="false"` (see Navigation) so the
  status-200 validation-error re-render displays correctly under Turbo Drive.

## Component: Events module + custom ingredient ("extending Alchemy")

Demonstrates a custom admin module, `resource_relations` for a belongs_to, and a
custom ingredient rendering an app record on a page. The Alchemy dummy app ships
this exact Event/Location scenario; we mirror it. Verified facts:

### Models & module (admin)

- `Event` (`app/models/event.rb`): `belongs_to :location` plus
  ```ruby
  def self.alchemy_resource_relations
    { location: { attr_method: "name", attr_type: "string" } }
  end
  ```
  This turns the `location_id` column into an `<alchemy-select>` of Locations in
  the admin form and shows `event.location.name` in the index table.
  (`alchemy_resource_relations` is **core**, not a separate gem.)
- `Location` (`app/models/location.rb`): `has_many :events` and a `name` column.
- Migrations: create `events` (name, description, starts_at, ends_at, lat/lng
  optional, `location_id`) and `locations` (name, address…).
- Controllers: `Admin::EventsController < Alchemy::Admin::ResourcesController`
  and `Admin::LocationsController < Alchemy::Admin::ResourcesController` (may be
  empty; admin CRUD views come from the engine).
- Routes (host `config/routes.rb`): `namespace :admin do resources :events;
  resources :locations end`, with `mount Alchemy::Engine => "/"` kept separate
  (not nested).
- Module registration (`config/initializers/alchemy_events.rb`):
  ```ruby
  Rails.application.config.to_prepare do
    Alchemy::Modules.register_module(
      name: "events",
      navigation: {
        name: "Events", controller: "/admin/events", action: "index",
        icon: "calendar",
        sub_navigation: [
          { name: "Events",    controller: "/admin/events",    action: "index" },
          { name: "Locations", controller: "/admin/locations", action: "index" }
        ]
      }
    )
  end
  ```

### Custom `Event` ingredient (Alchemy 8.3 uses ViewComponents)

- Model `app/models/alchemy/ingredients/event.rb`:
  ```ruby
  class Alchemy::Ingredients::Event < Alchemy::Ingredient
    related_object_alias :event, class_name: "Event"
    def preview_text(max_length = 30) = event&.name.to_s[0, max_length]
  end
  ```
  Reuses the existing polymorphic `related_object_*` columns — **no migration**
  for the ingredient. `type: Event` in elements.yml resolves to
  `Alchemy::Ingredients::Event` via `normalize_type` (convention; the class must
  live under `Alchemy::Ingredients`).
- Editor component `app/components/alchemy/ingredients/event_editor.rb`
  (`< Alchemy::Ingredients::BaseEditor`): override `input_field` to render a
  select writing to `form_field_name(:event_id)` (the alias's `event_id=` setter
  also sets `related_object_type`). Pattern mirrors `NodeEditor`/`PictureEditor`.
- View component `app/components/alchemy/ingredients/event_view.rb`
  (`< Alchemy::Ingredients::BaseView`): override `call` to render the event's
  name, date, and `event.location.name`.
- Element view (`event_teaser`) invokes it with `<%= el.render :event %>`.

The Events page uses `event_teaser` elements so an editor picks an `Event`
record and the page renders its details (including the related Location).

## Seeds & content (Phase 3)

- `db/seeds/alchemy/pages.yml`: the tour tree — Home (language root) with
  children Pages & Layouts, Elements, Ingredients, Nesting & Galleries, Blog
  (with post children), Events, Contact, Menus & Publishing, and a Thank-you
  page; plus the Footer layoutpage.
- Element default content (`elements.yml` `default:` values) carries the
  curriculum copy so autogenerated elements read as the tour.
- Picture seeding: keep `Demo::AlchemyPictureSeeder` (Cloudinary); update
  picture assignments to the new elements (hero, gallery, image_text, post
  headers). The integration test stubs the seeder (no network in tests).
- Menus: main_navigation and footer_navigation generated from `pages.yml`
  (as today).
- Mailer config + `contactform` seed (mail_to, success_page → Thank-you page).
- Events/Locations seed data (a handful of locations, several events).

## Testing

- Keep `test/integration/published_pages_test.rb` green throughout (renders
  every published page).
- Contact form: GET contact page renders the form (with hidden
  `contact_form_id`); POST valid params → redirect to Thank-you + flash +
  `ActionMailer::Base.deliveries` has one message (test delivery); POST invalid
  → re-renders with errors.
- Blog: overview renders and links to published child posts; teaser reads post
  header fields.
- Events: the Events page renders `event_teaser` with the related Location;
  admin resource index/form reachable (smoke).

## Deployment notes

- `tailwindcss-ruby` ships a platform binary; the lockfile already carries the
  needed linux/darwin platforms, so `BUNDLE_DEPLOYMENT=1` in the Dockerfile and
  Kamal deploy build Tailwind during `assets:precompile` (gem enhancement). No
  Node needed. (The Dockerfile still installs Node from the Foundation era;
  removing it is an optional, out-of-scope cleanup.)

## Decisions log

- CSS framework: Tailwind via `tailwindcss-rails` (standalone CLI, Node-free).
- Asset pipeline: Propshaft (Rails 8 default); Sprockets dropped as vestigial
  once Foundation's SCSS was gone.
- Navigation: Turbo Drive only (`turbo-rails` + `Turbo.start()`); no Frames /
  Streams; contact form opted out with `data-turbo="false"`.
- JS: importmap + Turbo; design targets zero custom JS (native first); Stimulus
  not installed — added only if a `clipboard_controller` is ever needed.
- Content: guided concept tour; the page explains itself via native `<details>`.
- Scope: redesign elements and page layouts (not just restyle); add Blog,
  Contact (Messages), and an Events custom module + custom ingredient.
- Brand: "Alchemy-lab" — violet/indigo base + emerald/lime potion accent.
- Contact: 3 fields (name/email/message), no real mail (test delivery), custom
  mailer template, dedicated Thank-you page.
- Delivery: three sequenced PRs (toolchain → elements/layouts → content/seeds).
