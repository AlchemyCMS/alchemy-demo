ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module DemoSeeding
  class << self
    attr_accessor :seeded
  end

  # The demo seeds (users, published pages, menus) are not idempotent and the
  # data is not rolled back between tests, so seed at most once per process and
  # let every test share the result. Truncate first so stale data left over from
  # a previous run (the DB is not transactional here) cannot mask a fresh seed.
  def seed_demo_once!
    return if DemoSeeding.seeded

    # The media seeders attach files via Active Storage/ImageMagick, which is
    # neither available nor needed in tests; pages render fine without them.
    Demo::AlchemyPictureSeeder.define_singleton_method(:seed!) { nil }
    Demo::AlchemyAttachmentSeeder.define_singleton_method(:seed!) { nil }

    require "database_cleaner/active_record"
    DatabaseCleaner.clean_with(:truncation)
    Rails.application.load_seed

    DemoSeeding.seeded = true
  end
end

class ActiveSupport::TestCase
  include DemoSeeding
end
