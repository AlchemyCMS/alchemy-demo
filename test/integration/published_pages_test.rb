require "test_helper"
require "alchemy/seeder" # db/seeds.rb expects Alchemy's db.rake to have loaded this

# Seeds the full demo into the test database and requests every published
# content page, guarding against regressions that break page rendering.
class PublishedPagesTest < ActionDispatch::IntegrationTest
  setup do
    # The demo picture seeder fetches images from Cloudinary over the network,
    # which is unavailable in tests. Replace it with a no-op so the rest of the
    # seeds still run; pages render without pictures.
    Demo::AlchemyPictureSeeder.define_singleton_method(:seed!) { nil }
    Rails.application.load_seed
  end

  test "every published content page renders successfully" do
    pages = Alchemy::Page.contentpages.published
    assert pages.any?, "expected the demo seeds to publish content pages"

    pages.each do |page|
      get page.url_path
      assert_response :success, "#{page.url_path} (#{page.name}) returned #{response.status}"
    end
  end
end
