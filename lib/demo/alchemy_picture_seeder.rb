# frozen_string_literal: true

require 'cloudinary'

module Demo
  module AlchemyPictureSeeder
    extend self

    def seed!
      puts "\nSeeding demo pictures"
      puts "---------------------"
      date = Date.current.to_s
      base_tags = %w(streetart germany erfurt graffiti)
      results = Cloudinary::Search.expression("public_id:streetart-erfurt*").execute
      results['resources'].each do |image|
        filename = "#{image['filename']}.#{image['format']}"
        tags = base_tags + (image['aspect_ratio'] >= 1.0 ? %w(landscape) : %w(portrait))
        Alchemy::Picture.create!(
          name: image['public_id'],
          upload_hash: date,
          image_file_name: filename,
          image_file_uid: filename,
          image_file_format: image['format'],
          image_file_size: image['bytes'],
          image_file_width: image['width'],
          image_file_height: image['height'],
          tag_list: tags
        )
        puts "== Created picture: #{filename}"
      end
    end
  end
end
