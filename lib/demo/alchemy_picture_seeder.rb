# frozen_string_literal: true

module Demo
  # Seeds Alchemy pictures from the sample images committed under
  # db/seeds/images, so the demo has real, self-contained images (no external
  # service) via the Active Storage adapter.
  module AlchemyPictureSeeder
    extend self

    IMAGES_DIR = Rails.root.join("db", "seeds", "images")

    def seed!
      puts "\nSeeding demo pictures"
      puts "---------------------"
      Dir.glob(IMAGES_DIR.join("*.{jpg,jpeg,png}")).sort.each do |path|
        filename = File.basename(path)
        picture = Alchemy::Picture.new(name: File.basename(path, ".*"))
        # content type is inferred from the filename by Active Storage
        picture.image_file.attach(io: File.open(path), filename: filename)
        picture.save!
        puts "== Created picture: #{filename}"
      end
    end
  end
end
