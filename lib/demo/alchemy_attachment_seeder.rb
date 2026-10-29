# frozen_string_literal: true

module Demo
  # Seeds Alchemy attachments from the sample media committed under
  # db/seeds/media, so the Audio, Video and File ingredients on the tour have
  # real, self-contained files (no external service) via the Active Storage
  # adapter.
  module AlchemyAttachmentSeeder
    extend self

    MEDIA_DIR = Rails.root.join("db", "seeds", "media")

    def seed!
      puts "\nSeeding demo attachments"
      puts "------------------------"
      Dir.glob(MEDIA_DIR.join("*")).sort.each do |path|
        next if File.directory?(path)
        next if File.extname(path) == ".md"

        filename = File.basename(path)
        attachment = Alchemy::Attachment.new
        attachment.file.attach(io: File.open(path), filename: filename)
        attachment.save!
        puts "== Created attachment: #{filename}"
      end
    end
  end
end
