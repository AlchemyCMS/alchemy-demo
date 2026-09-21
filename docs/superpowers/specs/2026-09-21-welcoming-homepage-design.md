# Design: A welcoming homepage — rewrite the demo's front door for evaluators

Date: 2026-09-21

## Overview

The demo homepage currently opens with the headline **"Build content like a
chemist."** and consists of four blocks: a `hero`, a `concept_grid` of three
cards, a standalone `button`, and a closing `cta`. Three of those four blocks
are the same call to action pointing at `#concepts`, so beyond three short
cards the page carries no content at all. Every line of copy describes
Alchemy's object model rather than what Alchemy does for the person reading.

This project rebuilds the homepage as a landing page for someone deciding
whether to adopt Alchemy, and establishes the voice that a later pass will roll
out across the rest of the demo.

### Goals

- Remove the chemistry metaphor from the homepage entirely.
- Give the page enough substance that it no longer reads as empty.
- Lead with what Alchemy does; introduce Elements and Ingredients only after
  the visitor knows why they'd care.
- Tell visitors about the platform capabilities the demo never mentions
  (SEO, multisite and languages, the JSON API, roles, scheduling, menus).
- Establish a documented voice that the demo-wide tone pass can follow.

### Non-goals (YAGNI)

- No rewrite of the tour pages (`/pages`, `/elements`, `/ingredients`,
  `/galleries`, blog, events, contact). Those stay developer-facing and get
  their own pass later.
- No new "Platform capabilities" page. The feature list covers the gap on the
  homepage; a dedicated page remains a separate, still-open piece of work.
- No admin redesign, no new JavaScript, no new gems.
- No demo login credentials in the hero — the admin invitation appears only in
  the closing CTA.

### Audience and voice

The homepage speaks to **evaluators** — someone asking "should we use
Alchemy?". The tour pages behind it keep speaking to **developers**. Two
voices, split by depth.

Voice rules for the homepage, which become the template for the later
demo-wide pass:

1. Second person. Address the reader, not the architecture.
2. Benefit before mechanism. Say what it gets you, then how it works.
3. Short sentences. One idea each.
4. **No chemistry metaphor anywhere** — no chemists, potions, alchemists,
   recipes, lab work, mixing or brewing, in any register including jokes.
5. Alchemy's product nouns — Page, Page Layout, Element, Ingredient — are kept
   and used plainly, because they are the real API names. They do not appear
   until the third block, after the reader knows what Alchemy does.
6. Claims must be true of the installed Alchemy, verified against its source.

## Page composition

The `home` page layout is recomposed to five blocks, top to bottom.

### 1. `hero` — existing element, extended

Gets a new `secondary_cta` Link ingredient so the hero can offer a primary
action and a quieter second door. `hero` is `unique: true` and used only by the
`home` layout, so adding the ingredient affects nothing else.

> **Build it your way. Let your team run it.**
>
> Alchemy is a content management system for Rails. You design the building
> blocks and own every line of markup — your editors add, arrange and publish
> pages without touching code.
>
> `[ Take the tour ]` → `/pages`  ·  `How this site is built →` → `#how`

### 2. `feature_list` + `feature_item` — new elements

A nestable `feature_list` holding eight `feature_item` children, rendered as a
responsive grid (one column, two at `sm`, four at `lg`).

This block does double duty: it is the substance the page was missing, and it
is the only place in the entire demo that tells a visitor Alchemy does SEO,
multisite, roles or caching. It closes the capability gap identified in the
2026-09 demo audit.

Headline: **"Everything you'd expect, already built in"**

| Item | Copy |
|---|---|
| Media library | Upload once, use anywhere. Crop an image differently for each place it appears without altering the original, and let the browser download only the size it needs. |
| Draft and publish | Every page has a draft you work on and a published version visitors see. Nothing goes live until you say so. |
| Publish on a schedule | Give a page a go-live date and an end date. Embargoed announcements and time-limited campaigns handle themselves. |
| Roles and restricted pages | Members-only sections, internal pages, and editors who can only reach what they should. |
| Built for search engines | Readable URLs, per-page titles and descriptions, robots settings, an automatic sitemap, and redirects that keep old links working when a page moves. |
| Languages and sites | Run several languages, several domains, or several separate sites from one installation. |
| Menus and shared content | Build navigation in the admin and reuse content across every page, the way this site's own footer does. |
| JSON API | Read your pages and elements as JSON — for a mobile app, a search index, or a separate frontend. Links to the live `/api/pages`. |

Every claim above is verified against the installed Alchemy source
(`alchemy_cms` 8.4.0.a, git checkout):

- Sitemap: `get "/sitemap.xml"` in `config/routes.rb`.
- Redirects: `Alchemy::LegacyPageUrl` model.
- SEO fields: `meta_description`, `robot_index`, `sitemap` columns on
  `alchemy_pages`.
- API: `namespace :api` exposes `pages`, `elements`, `ingredients`,
  `attachments` and `nodes`; `/api/pages` returns 200 with real data in this
  app. Note the API is *not* strictly read-only — it also has authenticated
  `patch :move` endpoints — so the copy says "read your pages and elements as
  JSON" rather than claiming read-only.
- Menus and global content: demonstrated by this demo's own `footer` layout
  page and `footer_nav` element.

### 3. `concept_grid` — existing element, rewritten copy

Same three cards and the existing `concept-pages.svg`, `concept-elements.svg`
and `concept-ingredients.svg` illustrations.

Headline: **"How Alchemy is put together"** (was "Core concepts")

- **Pages & Page Layouts** — Each page follows a layout that decides which
  blocks it can hold. Freedom where you want it, guardrails where you don't.
- **Elements** — The building blocks. Define one once, reuse it on any page,
  render it with your own template.
- **Ingredients** — The fields inside a block: text, rich text, pictures,
  links, dates. Each knows what it is, so editors get the right input for it.

Each card keeps its existing "Learn more" link into the tour.

### 4. `image_text` — existing element

Carries the `#how` anchor targeted by the hero's secondary CTA.

> **Curious how this page works?**
>
> This whole site is an Alchemy site — none of it is hardcoded. On any block,
> choose "How this block is built" to see its real definition, then jump
> straight into the admin and change it.

**Known gap:** the repository contains no screenshot of the Alchemy admin —
only six stock photos and four concept SVGs under `db/seeds/images/`. This
block will use a concept SVG. A real admin screenshot would serve it markedly
better and should be added later.

### 5. `cta` — existing element, rewritten copy

> **Have a go**
>
> The admin is open: sign in as **demo** / **demo123** and edit anything you
> see here.
>
> `[ Open the admin ]` → `/admin`

### Removed from the page

`button` moves out of the `home` layout's `autogenerate:` list but stays in its
`elements:` list. It is no longer the third identical "go to `#concepts`" link
on the page, but remains addable in the admin, where it still serves as the
demo's showcase for the Color ingredient.

## New element definitions

### `feature_list`

Nestable parent. Ingredients:

- `headline` — Headline, levels/sizes `[2, 3]`, default `:feature_list_headline`
- `lead` — Richtext, optional, sanitizer limited to `p, br, strong, em, a`

`nestable_elements: [feature_item]`.

### `feature_item`

Ingredients:

- `icon` — Select, from a fixed list whose values map to inline SVG paths in
  the partial. Using a Select rather than a Picture keeps the icons out of the
  seeded image set, and demonstrates the Select ingredient on the homepage.
- `title` — Headline, levels/sizes `[3, 4]`, `as_element_title: true`
- `description` — Richtext, sanitizer limited to `p, br, strong, em, a`
- `link` — Link, optional

Icon Select values (eight, one per seeded item, each a heroicons-style outline
path inlined in `_feature_item.html.erb`): `photo`, `document-duplicate`,
`clock`, `lock-closed`, `magnifying-glass`, `globe-alt`, `bars-3`, `code`.

## Partials

- `app/views/alchemy/elements/_feature_list.html.erb` — section wrapper,
  headline, optional lead, responsive grid of nested elements, and the shared
  reveal. Wrapper carries `group`.
- `app/views/alchemy/elements/_feature_item.html.erb` — icon, title,
  description, optional link. **No reveal**, and **no `group` class**: it is a
  child of an element that already carries one, and a nested `group` is exactly
  what produced the duplicate-reveal bug fixed in `aa664e5`.

Both follow existing conventions: `cache(element)`, `element_view_for`, brand
tokens from `app/assets/tailwind/application.css`, no new JavaScript.

## Where the copy lives

- `config/locales/alchemy.en.yml` under `default_ingredient_texts` — the
  defaults an editor sees when adding a fresh block, plus new
  `ingredient_hints` and `element_hints` for the two new elements.
- `db/seeds.rb` — the homepage's actual content, following the existing
  `concept_card` override pattern: look elements up by page and name, set each
  ingredient. The eight feature items are seeded from a literal list in the
  same style as the concept cards.

Homepage seeding must run **before** the section-wrapping block near the end of
`db/seeds.rb`. That block skips the `home` layout, so the homepage is not
banded into sections, but ordering still matters for consistency with how every
other content override in the file is arranged.

## Testing

- `test/integration/published_pages_test.rb` already requests every published
  page and asserts a 200; it covers the new elements rendering without error.
- Add an assertion that the homepage renders eight feature items and that the
  API feature item links to `/api/pages`.
- Verify that each seeded feature item's icon Select value resolves to a real
  SVG in the partial, so a typo cannot silently render a blank icon.
- Manual check: exactly one reveal button per block on the homepage.

## Risks

- **Marketing claims drifting from reality.** Mitigated by verifying each claim
  against the installed source, recorded above. Any future item added to the
  feature list must clear the same bar.
- **The homepage becomes the only honest page.** Rewriting the front door in a
  warm voice while the tour pages stay terse makes the seam more visible, not
  less. The demo-wide pass should follow reasonably soon.
- **No admin screenshot** weakens the "see it yourself" block, as noted above.

## Follow-up work, explicitly out of scope

1. The demo-wide tone pass across the tour pages, using this document's voice
   rules as the template.
2. A dedicated "Platform capabilities" page covering caching and page locking
   in depth — the parts the feature list names but does not explain.
3. An admin screenshot in `db/seeds/images/`.
