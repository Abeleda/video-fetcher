json_credentials = File.open(Rails.root.join('credentials.json').to_s, 'r').read
credentials = JSON.parse(json_credentials).deep_symbolize_keys

FACEBOOK_APPS = credentials[:facebook]
VIMEO_ACCESS_TOKEN = credentials[:vimeo][:access_token]
YOUTUBE_API_KEY = credentials[:youtube][:api_key]