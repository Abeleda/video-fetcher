DEBUG = Rails.env.development? ? true : false

Yt.configure do |config|
  config.api_key = YOUTUBE_API_KEY
  config.log_level = :devel if DEBUG
end