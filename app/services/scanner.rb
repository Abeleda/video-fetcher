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
      oauth = Koala::Facebook::OAuth.new(FACEBOOK_APP_ID, FACEBOOK_APP_SECRET)
      token = oauth.get_app_access_token
      @graph = Koala::Facebook::API.new(token)
      # ?id=https://www.facebook.com/nike/
      user = @graph.get_object "?id=#{@channel.url}"
      shares = []
      feed = @graph.get_connection(user['id'], 'feed/?fields=object_id,source,name,created_time,updated_time,id,type,properties,shares')

      filtered_feed = []
      feed.each {|f|
        if f['type'] && f['type'] == 'video'
          filtered_feed << f
          if f['shares'] && f['shares']['count']
            shares << f['shares']['count']
          else
            shares << 0
          end
        end
      }
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

      likes = @graph.batch do |batch_api|
        videos.each do |video|
          batch_api.get_connection(video.uid, 'likes?summary=true')
        end
      end
      likes_objects = []
      ActiveRecord::Base.transaction do
        (0...likes.count).each do |i|
          likes_objects << Metadata.create!(likes: likes[i].raw_response['summary']['total_count'], video_id: videos[i].id, shares: shares[i])
        end
      end


      comments = @graph.batch do |batch_api|
        videos.each do |video|
          batch_api.get_connection(video.uid, 'comments?summary=true')
        end
      end
      comments_objects = []
      ActiveRecord::Base.transaction do
        (0...comments.count).each do |i|
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