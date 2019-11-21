# frozen_string_literal: true

require 'database_cleaner'

namespace :demo do
  desc "Reset the demo content"
  task reset: :environment do
    puts "Resetting database"
    DatabaseCleaner.clean_with(:truncation, reset_ids: true)
    Rake::Task['db:schema:load'].invoke
    Rake::Task['db:seed'].invoke
    puts "Clearing cache"
    Rails.cache.clear
    puts "Done."
  end
end
