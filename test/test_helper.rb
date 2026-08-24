ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module DemoSeeding
  # The demo seeds (users, published pages, menus) are not idempotent and the
  # data is not rolled back between tests, so seed at most once per process and
  # let every test share the result.
  def seed_demo_once!
    return if Alchemy::Page.exists?

    # The picture seeder attaches image files via ImageMagick, which is neither
    # available nor needed in tests; pages render fine without pictures.
    Demo::AlchemyPictureSeeder.define_singleton_method(:seed!) { nil }
    Rails.application.load_seed
  end
end

class ActiveSupport::TestCase
  include DemoSeeding
end
