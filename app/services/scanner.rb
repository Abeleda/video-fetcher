class Scanner

  def initialize(channel)
    @channel = channel
  end

  def scan
    if @channel.youtube?
      yt = Yt::Channel.new url: @channel.url
      yt.videos.each do |v|
        p v.title, v.published_at, v.duration
        # @channel.videos.create!(
        #   title: v.title,
        #   published: v.published_at,
        #   duration: v.duration
        # )
      end
    elsif @channel.facebook?
      app_id = '206850539666337'
      app_secret = '2d56fac698a6eafc3956d26731ea3f2c'
      callback_url = 'http://localhost:3000/oauth'
      oauth = Koala::Facebook::OAuth.new(app_id, app_secret, callback_url)
      token = oauth.get_app_access_token
      graph = Koala::Facebook::API.new(token)
      # ?id=https://www.facebook.com/nike/
      user = graph.get_object "?id=#{@channel.url}"

      feed = graph.get_connection(user['id'], 'feed/?fields=object_id,source,name,created_time,updated_time')
      puts feed.count
      filtered_feed = []
      feed.each {|f| filtered_feed << f if f['source']}

      # Potential problems
      # 1. No API for duration
      # 2. Need to check if present?
      filtered_feed.each do |f|
        @channel.videos.create(title: f['name'], url: f['source'], published: f['created_time'], modified: f['updated_time'])
      end

    end
  end

end