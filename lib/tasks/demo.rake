# frozen_string_literal: true

namespace :demo do
  desc "Reset the demo content"
  task reset: :environment do
    puts "Resetting database"
    Rake::Task['db:reset'].invoke
    Rake::Task['db:seed'].invoke
  end
end
