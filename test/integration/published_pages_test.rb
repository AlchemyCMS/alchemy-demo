require "test_helper"
require "alchemy/seeder" # db/seeds.rb expects Alchemy's db.rake to have loaded this

# Seeds the full demo into the test database and requests every published
# content page, guarding against regressions that break page rendering.
class PublishedPagesTest < ActionDispatch::IntegrationTest
  # The demo seed is not rolled back cleanly (Alchemy::Seeder skips page
  # creation once a Site/Language is present), so seed once and keep it.
  self.use_transactional_tests = false

  setup { seed_demo_once! }

  test "every published content page renders successfully" do
    pages = Alchemy::Page.contentpages.published
    assert pages.any?, "expected the demo seeds to publish content pages"

    pages.each do |page|
      get page.url_path
      assert_response :success, "#{page.url_path} (#{page.name}) returned #{response.status}"
    end
  end

  test "the ingredients catalog renders a row for every ingredient type" do
    get "/ingredients"
    assert_response :success

    badges = css_select("dl dt span.font-mono").map(&:text)
    %w[Text Headline Richtext Picture Link Page Node Select Color Datetime
      Boolean Number Html Audio Video File Event].each do |type|
      assert_includes badges, type, "catalog is missing a #{type} row"
    end

    headings = css_select("section h2").map(&:text)
    ["Content ingredients", "Media ingredients", "Reference ingredients"].each do |title|
      assert_includes headings, title, "catalog is missing the #{title.inspect} section"
    end
  end

  test "the galleries page renders the slider element and both gallery layouts" do
    get "/galleries"
    assert_response :success

    slider = css_select("alchemy-slider").first
    assert slider, "expected an <alchemy-slider> element"
    assert_not_nil slider["autoplay"], "the seeded slider should autoplay"
    assert_equal "1", slider["per-slide"]
    assert css_select("alchemy-slider [data-slider-track] figure").any?, "slider should render slides"

    assert css_select("div.grid-cols-2 figure").any?, "expected a grid gallery"
    assert css_select("div.columns-2 figure").any?, "expected a masonry gallery"
  end
end
