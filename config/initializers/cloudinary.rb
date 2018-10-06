if Rails.application.credentials.cloudinary
  Cloudinary.config do |config|
    config.cloud_name = Rails.application.credentials.cloudinary[:cloud_name]
    config.api_key    = Rails.application.credentials.cloudinary[:api_key]
    config.api_secret = Rails.application.credentials.cloudinary[:api_secret]
    config.secure = true
    config.cdn_subdomain = true
  end
else
  Rails.logger.info { puts "****** Warning: There is no 'cloudinary' section in the credentials file. 'See Readme.MD' for details." }
end