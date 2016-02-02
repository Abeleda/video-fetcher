class Scanner

  # TO-DO:
  # 1. Fetch comments
  # 2. Fetch views
  # 3. Fetch shares
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
      @graph = Koala::Facebook::API.new(token)
      # ?id=https://www.facebook.com/nike/
      user = @graph.get_object "?id=#{@channel.url}"
      puts user

      feed = @graph.get_connection(user['id'], 'feed/?fields=object_id,source,name,created_time,updated_time,id,type,properties')
      # puts feed
      filtered_feed = []
      feed.each {|f| filtered_feed << f if f['type'] && f['type'] == 'video'}
      # Potential problems
      # 1. No API for duration
      # 2. Need to check if present?
      videos = []
      ActiveRecord::Base.transaction do
        filtered_feed.each do |f|
          time = get_video_length f
          video = Video.find_by(uid: f['id'])
          if video
            videos << video
          else
            v = Video.new(title: f['name'], url: f['source'], published: f['created_time'], modified: f['updated_time'], uid: f['id'], channel_id: @channel.id)
            v.duration = time
            v.save!
            videos << v
          end
        end
      end

      puts videos.count
      likes = @graph.batch do |batch_api|
        videos.each do |video|
          puts video.uid
          batch_api.get_connection(video.uid, 'likes?summary=true')
        end
      end
      likes_objects = []
      puts likes.count
      ActiveRecord::Base.transaction do
        (0...likes.count).each do |i|
          puts videos[i].id
          likes_objects << Like.create!(amount: likes[i].raw_response['summary']['total_count'], video_id: videos[i].id)
        end
      end


      comments = @graph.batch do |batch_api|
        videos.each do |video|
          batch_api.get_connection(video.uid, 'comments?summary=true')
        end
      end
      # puts comments
      # comments.each do |comment|
      #   puts comment.raw_response
      #   break
      # end
      comments_objects = []
      ActiveRecord::Base.transaction do
        (0...comments.count).each do |i|
          puts i
          likes_objects[i].update_attribute(:comments, comments[i].raw_response['summary']['total_count'])
          video = videos[i]
          comments[i].each do |comment|
            begin
              c = Comment.find_or_create_by!(uid: comment['id'], content: comment['message'], video_id: video.id)
              comments_objects << c

            rescue
              puts 'ERROR: INVALID COMMENT'
            end
          end
        end
      end



    end
  end

  private
  def get_video_length(post)
    # Possible error - works only with format "MM:SS"
    if post['properties']
      post['properties'].each do |property|
        if property['name'] == 'Length'
          return parse_time property['text']
        end
      end
    else
      nil
    end
  end


  def parse_time(text)
    # Possible error - works only with format "MM:SS"
    arr = text.split(':')
    minutes = arr[0].to_i
    seconds = arr[1].to_i
    minutes * 60 + seconds
  end
end