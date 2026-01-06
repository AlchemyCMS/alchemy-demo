# frozen_string_literal: true

require "database_cleaner"

namespace :demo do
  task build: ["assets:precompile", "assets:clean"]

  desc "Reset the demo content"
  task reset: :environment do
    puts "Preparing database"
    Rake::Task["db:prepare"].invoke
    puts "Resetting database"
    DatabaseCleaner.clean_with(:truncation)
    Rake::Task["db:seed"].invoke
    puts "Clearing cache"
    Rails.cache.clear
    puts "Done."
  end
end
