# Phase 2.1 — Frontend Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish the Alchemy-lab Tailwind design system and restyle the shared site chrome (header, navigation, footer, flash) plus the reusable self-explaining "reveal" partial — so every page renders with styled chrome while element bodies remain to be styled in Phase 2.2.

**Architecture:** Tailwind v4 theme tokens defined with `@theme` in the single Tailwind entry stylesheet. The shared chrome partials (`app/views/shared/*`, `app/views/alchemy/menus/*`) are restyled in place with Tailwind utilities; page-layout partials are NOT touched in this plan (they still call `render 'shared/header'` / `render 'shared/footer'`, which now render styled). Interactivity is native HTML/CSS only — the mobile menu is a `<details>` disclosure. A new `reveal` helper + partial introspect a live Alchemy element to render its definition.

**Tech Stack:** Rails 8.1, Ruby 4.0, Alchemy CMS 8.3.6, Tailwind CSS v4 via `tailwindcss-rails` (standalone CLI, no Node), Propshaft, Turbo Drive.

**Spec:** `docs/superpowers/specs/2026-08-20-tailwind-alchemy-demo-design.md`

## Global Constraints

- Work happens on a branch off `tailwind-migration` (never `main` — merging to `main` auto-deploys the live demo). Create it at execution start: `git checkout tailwind-migration && git pull && git checkout -b feat/phase2-1-frontend-foundation`.
- Node-free: only the standalone Tailwind CLI via `bin/rails tailwindcss:build`. No npm/yarn, no `package.json`.
- Native HTML/CSS first: no custom JavaScript, no Stimulus (it is not installed). Turbo Drive is active — do not add markup that breaks full-page navigation.
- Propshaft pipeline: assets under `app/assets` are served automatically; the Tailwind source is `app/assets/tailwind/application.css`, built to `app/assets/builds/tailwind.css` (gitignored).
- Tailwind v4 scans source files for utility classes at build time. After any change to ERB classes or the theme, rebuild with `bin/rails tailwindcss:build` before verifying.
- Palette: `brand-*` = violet scale, `potion-*` = emerald scale (Alchemy-lab).
- The `test/integration/published_pages_test.rb` suite must stay green after every task.
- Do NOT edit any file under `app/views/alchemy/page_layouts/` or `app/views/alchemy/elements/` in this plan — those belong to Phase 2.2.

---

## File Structure

- `app/assets/tailwind/application.css` — Tailwind entry + `@theme` tokens (modify).
- `app/views/layouts/application.html.erb` — add font links + flash render (modify).
- `app/views/shared/_flash.html.erb` — flash banner partial (create).
- `app/views/shared/_default_header.html.erb` — site header + nav (modify).
- `app/views/shared/_microsite_header.html.erb` — restricted/microsite header (modify, minimal).
- `app/views/shared/_footer.html.erb` — site footer (modify).
- `app/views/alchemy/menus/main_navigation/_wrapper.html.erb` / `_node.html.erb` — main nav (modify).
- `app/views/alchemy/menus/footer_navigation/_wrapper.html.erb` / `_node.html.erb` — footer nav (modify).
- `app/helpers/alchemy_reveal_helper.rb` — element-introspection helper (create).
- `app/views/shared/_reveal.html.erb` — "how this block is built" `<details>` (create).
- `test/helpers/alchemy_reveal_helper_test.rb` — helper unit test (create).

---

## Task 1: Alchemy-lab Tailwind theme

**Files:**
- Modify: `app/assets/tailwind/application.css`

**Interfaces:**
- Produces: Tailwind color utilities `*-brand-{50..950}` (violet) and `*-potion-{50..950}` (emerald), and `font-display` / `font-sans` families. Later tasks and Phase 2.2 consume these class names.

- [ ] **Step 1: Replace the Tailwind entry with theme tokens**

Replace the entire contents of `app/assets/tailwind/application.css` with:

```css
@import "tailwindcss";

@theme {
  --font-sans: "Inter", ui-sans-serif, system-ui, sans-serif;
  --font-display: "Space Grotesk", ui-sans-serif, system-ui, sans-serif;

  /* brand = violet */
  --color-brand-50: #f5f3ff;
  --color-brand-100: #ede9fe;
  --color-brand-200: #ddd6fe;
  --color-brand-300: #c4b5fd;
  --color-brand-400: #a78bfa;
  --color-brand-500: #8b5cf6;
  --color-brand-600: #7c3aed;
  --color-brand-700: #6d28d9;
  --color-brand-800: #5b21b6;
  --color-brand-900: #4c1d95;
  --color-brand-950: #2e1065;

  /* potion = emerald */
  --color-potion-50: #ecfdf5;
  --color-potion-100: #d1fae5;
  --color-potion-200: #a7f3d0;
  --color-potion-300: #6ee7b7;
  --color-potion-400: #34d399;
  --color-potion-500: #10b981;
  --color-potion-600: #059669;
  --color-potion-700: #047857;
  --color-potion-800: #065f46;
  --color-potion-900: #064e3b;
  --color-potion-950: #022c22;
}
```

- [ ] **Step 2: Build and verify the tokens compile**

Run: `bin/rails tailwindcss:build`
Then: `grep -c "color-brand-600" app/assets/builds/tailwind.css`
Expected: build prints "Done"; grep count is `>= 1` (the `:root` custom properties are emitted).

- [ ] **Step 3: Commit**

```bash
git add app/assets/tailwind/application.css
git commit -m "feat(theme): add alchemy-lab tailwind theme tokens"
```

---

## Task 2: Font loading + flash banners

**Files:**
- Modify: `app/views/layouts/application.html.erb`
- Create: `app/views/shared/_flash.html.erb`

**Interfaces:**
- Consumes: Task 1 `font-sans` / `font-display` families and `brand`/`potion` colors.
- Produces: a `shared/flash` partial rendered on every page; the `<body>` gains the base font/background classes later tasks assume.

- [ ] **Step 1: Create the flash partial**

Create `app/views/shared/_flash.html.erb`:

```erb
<% flash.each do |type, message| %>
  <% styles = type.to_s == "alert" ? "bg-red-50 text-red-800 border-red-200" : "bg-potion-50 text-potion-800 border-potion-200" %>
  <div class="border-b <%= styles %>" role="status">
    <p class="mx-auto max-w-5xl px-4 py-3 text-sm font-medium"><%= message %></p>
  </div>
<% end %>
```

- [ ] **Step 2: Add fonts and flash to the layout**

In `app/views/layouts/application.html.erb`, add these two lines in `<head>` immediately after the `<meta name="viewport" ...>` line:

```erb
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Space+Grotesk:wght@500;600;700&display=swap">
```

Then change the `<body>` opening tag from `<body>` to:

```erb
  <body class="min-h-screen bg-white font-sans text-slate-700 antialiased">
    <%= render "shared/flash" %>
```

(Leave the existing `<%= yield %>`, preview-mode, and menubar renders unchanged.)

- [ ] **Step 3: Rebuild Tailwind and run the integration test**

Run: `bin/rails tailwindcss:build`
Run: `bin/rails db:test:prepare && bin/rails test test/integration/published_pages_test.rb`
Expected: PASS — `1 runs, 8 assertions, 0 failures, 0 errors`.

- [ ] **Step 4: Commit**

```bash
git add app/views/layouts/application.html.erb app/views/shared/_flash.html.erb
git commit -m "feat(chrome): load fonts and render flash banners in the layout"
```

---

## Task 3: Main navigation partials

**Files:**
- Modify: `app/views/alchemy/menus/main_navigation/_wrapper.html.erb`
- Modify: `app/views/alchemy/menus/main_navigation/_node.html.erb`

**Interfaces:**
- Consumes: Alchemy's `render_menu('main_navigation')` (renders `_wrapper`, which renders `_node` per node). `node` responds to `url`, `name`, `external?`, `nofollow?`. `@preview_mode` may be set.
- Produces: a `<ul>` of styled nav links used by both the desktop bar and the mobile `<details>` in Task 4. The main nav is intentionally flat — child nodes (e.g. blog posts) are not rendered as dropdowns.

- [ ] **Step 1: Restyle the wrapper**

Replace the contents of `app/views/alchemy/menus/main_navigation/_wrapper.html.erb` with:

```erb
<ul class="flex flex-col gap-1 md:flex-row md:items-center md:gap-1">
  <%= render partial: options[:node_partial_name],
    collection: menu.children.includes(:page, :children),
    locals: { options: options },
    as: 'node' %>
</ul>
```

- [ ] **Step 2: Restyle the node**

Replace the contents of `app/views/alchemy/menus/main_navigation/_node.html.erb` with:

```erb
<li>
  <%= link_to_if node.url,
    node.name,
    @preview_mode ? 'javascript: void(0)' : node.url,
    class: [
      'block rounded-md px-3 py-2 text-sm font-medium transition-colors',
      current_page?(node.url) ? 'bg-brand-50 text-brand-700' : 'text-slate-600 hover:bg-slate-50 hover:text-brand-700'
    ].compact.join(' '),
    target: node.external? ? '_blank' : nil,
    rel: node.nofollow? ? 'nofollow' : nil %>
</li>
```

- [ ] **Step 3: Rebuild Tailwind and run the integration test**

Run: `bin/rails tailwindcss:build`
Run: `bin/rails test test/integration/published_pages_test.rb`
Expected: PASS — `0 failures, 0 errors`.

- [ ] **Step 4: Commit**

```bash
git add app/views/alchemy/menus/main_navigation/
git commit -m "feat(nav): restyle main navigation with tailwind"
```

---

## Task 4: Site header with native mobile menu

**Files:**
- Modify: `app/views/shared/_default_header.html.erb`

**Interfaces:**
- Consumes: `@page` (responds to `title`), `render_menu('main_navigation')` (Task 3), `alchemy.root_path` for the wordmark link.
- Produces: the styled `<header>` used by `shared/_header` for non-restricted pages.

- [ ] **Step 1: Restyle the header with a `<details>` mobile menu**

Replace the contents of `app/views/shared/_default_header.html.erb` with:

```erb
<header class="border-b border-slate-100 bg-white/90 backdrop-blur supports-backdrop-blur:bg-white/70 sticky top-0 z-40">
  <div class="mx-auto flex max-w-5xl items-center justify-between px-4 py-3">
    <%= link_to alchemy.root_path, class: "font-display text-lg font-700 tracking-tight text-brand-700" do %>
      Alchemy<span class="text-potion-500">CMS</span>
    <% end %>

    <nav class="hidden md:block" aria-label="Main">
      <%= render_menu('main_navigation') %>
    </nav>

    <details class="md:hidden group relative">
      <summary class="list-none cursor-pointer rounded-md p-2 text-slate-600 hover:bg-slate-50" aria-label="Menu">
        <svg class="h-6 w-6 group-open:hidden" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" /></svg>
        <svg class="h-6 w-6 hidden group-open:block" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" /></svg>
      </summary>
      <div class="absolute right-0 mt-2 w-56 rounded-lg border border-slate-100 bg-white p-2 shadow-lg">
        <%= render_menu('main_navigation') %>
      </div>
    </details>
  </div>
</header>
```

- [ ] **Step 2: Rebuild Tailwind and run the integration test**

Run: `bin/rails tailwindcss:build`
Run: `bin/rails test test/integration/published_pages_test.rb`
Expected: PASS — `0 failures, 0 errors`.

- [ ] **Step 3: Commit**

```bash
git add app/views/shared/_default_header.html.erb
git commit -m "feat(chrome): restyle site header with native mobile menu"
```

---

## Task 5: Footer + footer navigation

**Files:**
- Modify: `app/views/shared/_footer.html.erb`
- Modify: `app/views/alchemy/menus/footer_navigation/_wrapper.html.erb`
- Modify: `app/views/alchemy/menus/footer_navigation/_node.html.erb`

**Interfaces:**
- Consumes: `footer_page` local (may be nil), `render_elements(only: ..., from_page: footer_page)`, `render_menu('footer_navigation')`. NOTE: it still renders the current `footer_note` and `social_button` elements — those element names/partials are updated in Phase 2.2; do not rename them here.

- [ ] **Step 1: Restyle the footer**

Replace the contents of `app/views/shared/_footer.html.erb` with:

```erb
<footer class="mt-24 bg-brand-950 text-brand-100">
  <div class="mx-auto max-w-5xl px-4 py-12">
    <% if footer_page %>
      <div class="grid gap-8 md:grid-cols-3">
        <div class="text-sm/6 text-brand-200">
          <%= render_elements(only: 'footer_note', from_page: footer_page) %>
        </div>
        <div class="flex items-start gap-3">
          <%= render_elements(only: 'social_button', from_page: footer_page) %>
        </div>
        <nav aria-label="Footer">
          <%= render_menu('footer_navigation') %>
        </nav>
      </div>
    <% end %>
  </div>
</footer>
```

- [ ] **Step 2: Restyle the footer nav wrapper**

Replace the contents of `app/views/alchemy/menus/footer_navigation/_wrapper.html.erb` with:

```erb
<ul class="flex flex-col gap-2 md:items-end">
  <%= render partial: options[:node_partial_name],
    collection: menu.children.includes(:page, :children),
    locals: { options: options },
    as: 'node' %>
</ul>
```

- [ ] **Step 3: Restyle the footer nav node**

Replace the contents of `app/views/alchemy/menus/footer_navigation/_node.html.erb` with:

```erb
<li>
  <%= link_to_if node.url,
    node.name,
    @preview_mode ? 'javascript: void(0)' : node.url,
    class: 'text-sm text-brand-200 hover:text-white transition-colors',
    target: node.external? ? '_blank' : nil,
    rel: node.nofollow? ? 'nofollow' : nil %>
</li>
```

- [ ] **Step 4: Rebuild Tailwind and run the integration test**

Run: `bin/rails tailwindcss:build`
Run: `bin/rails test test/integration/published_pages_test.rb`
Expected: PASS — `0 failures, 0 errors`.

- [ ] **Step 5: Commit**

```bash
git add app/views/shared/_footer.html.erb app/views/alchemy/menus/footer_navigation/
git commit -m "feat(chrome): restyle footer and footer navigation"
```

---

## Task 6: Microsite / restricted header (minimal restyle)

**Files:**
- Modify: `app/views/shared/_microsite_header.html.erb`

**Interfaces:**
- Consumes: `@page` (responds to `parent`, `title`, `level`), the `microsite` local, and the existing Alchemy helpers `show_alchemy_page_path` and `render_subnavigation`. Preserve every helper call and its arguments exactly — only swap Foundation classes for Tailwind on the wrapper elements.

- [ ] **Step 1: Restyle only the wrapper markup**

Replace the contents of `app/views/shared/_microsite_header.html.erb` with (helper calls unchanged from the original; only classes/markup changed):

```erb
<nav class="border-b border-slate-100 bg-white">
  <div class="mx-auto flex max-w-5xl items-center justify-between px-4 py-3">
    <div class="font-display text-lg font-600 text-brand-700">
      <% parent = @page.parent %>
      <% if parent.level > 1 %>
        <%= link_to show_alchemy_page_path(parent), class: "hover:text-brand-800" do %>
          &laquo; <%= parent.title %>
        <% end %>
      <% else %>
        <%= link_to show_alchemy_page_path(@page), class: "hover:text-brand-800" do %>
          <%= @page.title %>
        <% end %>
      <% end %>
    </div>

    <% if microsite %>
      <div class="flex items-center gap-2 text-sm">
        <%= render_subnavigation(
          {
            from_page: microsite.parent,
            spacer: '',
            navigation_partial: 'alchemy/navigation/microsite_renderer'
          },
          {
            class: 'flex items-center gap-2'
          }
        ) %>
      </div>
    <% end %>
  </div>
</nav>
```

- [ ] **Step 2: Rebuild Tailwind and run the integration test**

Run: `bin/rails tailwindcss:build`
Run: `bin/rails test test/integration/published_pages_test.rb`
Expected: PASS — `0 failures, 0 errors`.

- [ ] **Step 3: Commit**

```bash
git add app/views/shared/_microsite_header.html.erb
git commit -m "feat(chrome): restyle microsite header with tailwind"
```

---

## Task 7: Self-explaining "reveal" helper + partial

**Files:**
- Create: `app/helpers/alchemy_reveal_helper.rb`
- Create: `app/views/shared/_reveal.html.erb`
- Test: `test/helpers/alchemy_reveal_helper_test.rb`

**Interfaces:**
- Produces: `AlchemyRevealHelper#element_source(element)` → a Hash `{ name: String, ingredients: [[role, type], ...], nested: [String, ...] }`. The `shared/reveal` partial (rendered as `render "shared/reveal", element: element`) consumes it. Phase 2.2 element partials call this partial.

- [ ] **Step 1: Write the failing helper test**

Create `test/helpers/alchemy_reveal_helper_test.rb`:

```ruby
require "test_helper"

class AlchemyRevealHelperTest < ActionView::TestCase
  include AlchemyRevealHelper

  # Minimal doubles standing in for Alchemy::Element / Alchemy::Ingredient so the
  # helper's introspection is unit-tested without touching the database.
  Ingredient = Struct.new(:role, :type)
  FakeElement = Struct.new(:name, :ingredients, :nested_elements)

  test "element_source summarizes name, ingredient roles/types and nested names" do
    element = FakeElement.new(
      "image_text",
      [Ingredient.new("headline", "Alchemy::Ingredients::Text"),
       Ingredient.new("image", "Alchemy::Ingredients::Picture")],
      [FakeElement.new("gallery_image", [], [])]
    )

    result = element_source(element)

    assert_equal "image_text", result[:name]
    assert_equal [["headline", "Text"], ["image", "Picture"]], result[:ingredients]
    assert_equal ["gallery_image"], result[:nested]
  end
end
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bin/rails test test/helpers/alchemy_reveal_helper_test.rb`
Expected: FAIL with `uninitialized constant AlchemyRevealHelper`.

- [ ] **Step 3: Implement the helper**

Create `app/helpers/alchemy_reveal_helper.rb`:

```ruby
module AlchemyRevealHelper
  # Introspects a live Alchemy element into a plain hash describing how it is
  # built, so the "reveal" partial can show an always-accurate definition.
  def element_source(element)
    {
      name: element.name,
      ingredients: element.ingredients.map { |i| [i.role, i.type.to_s.demodulize] },
      nested: element.nested_elements.map(&:name)
    }
  end
end
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `bin/rails test test/helpers/alchemy_reveal_helper_test.rb`
Expected: PASS — `1 runs, 3 assertions, 0 failures, 0 errors`.

- [ ] **Step 5: Create the reveal partial**

Create `app/views/shared/_reveal.html.erb`:

```erb
<% source = element_source(element) %>
<details class="group mt-6 rounded-lg border border-brand-100 bg-brand-50/50">
  <summary class="flex cursor-pointer list-none items-center gap-2 px-4 py-2 text-sm font-medium text-brand-700">
    <span class="text-potion-500">🔍</span>
    How this block is built
    <span class="ml-auto text-xs text-brand-400 group-open:hidden">show</span>
    <span class="ml-auto hidden text-xs text-brand-400 group-open:inline">hide</span>
  </summary>
  <div class="border-t border-brand-100 px-4 py-3 font-mono text-xs text-slate-600">
    <p class="mb-2"><span class="text-brand-500">element</span>: <%= source[:name] %></p>
    <% if source[:ingredients].any? %>
      <p class="text-brand-500">ingredients:</p>
      <ul class="ml-3">
        <% source[:ingredients].each do |role, type| %>
          <li><%= role %> <span class="text-slate-400">→</span> <%= type %></li>
        <% end %>
      </ul>
    <% end %>
    <% if source[:nested].any? %>
      <p class="mt-2 text-brand-500">nestable: <span class="text-slate-600"><%= source[:nested].uniq.join(", ") %></span></p>
    <% end %>
  </div>
</details>
```

- [ ] **Step 6: Rebuild Tailwind and run the full test suite**

Run: `bin/rails tailwindcss:build`
Run: `bin/rails test`
Expected: PASS — all tests green (integration + the new helper test).

- [ ] **Step 7: Commit**

```bash
git add app/helpers/alchemy_reveal_helper.rb app/views/shared/_reveal.html.erb test/helpers/alchemy_reveal_helper_test.rb
git commit -m "feat(reveal): add self-explaining element reveal helper and partial"
```

---

## Done criteria

- The Alchemy-lab theme tokens are available as `brand-*` / `potion-*` utilities and the display/body fonts load.
- Header, main nav, footer, footer nav, and microsite header render with Tailwind styling; the mobile menu opens/closes natively via `<details>`.
- Flash messages render as styled banners (verified live on the contact flow in Phase 2.2).
- `render "shared/reveal", element: element` renders an accurate, native `<details>` definition for any element (consumed by Phase 2.2).
- `bin/rails test` is green.
