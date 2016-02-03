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
      while @graph_collection.nil? || @graph_collection != []
        if @graph_collection.nil?
          @graph_collection = @graph.get_connection(user['id'], 'feed/?fields=object_id,source,name,created_time,updated_time,id,type,properties,shares')
        else
          @graph_collection = @graph_collection.next_page
        end
        filtered_feed = []
        @graph_collection.each { |f|
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
            v = Video.find_or_initialize_by(title: f['name'], url: f['source'], published: f['created_time'], modified: f['updated_time'], uid: f['id'], channel_id: @channel.id, attachment: f['object_id'])
            v.save! unless v.persisted?
            videos << v
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
        video_infos = @graph.batch do |batch_api|
          videos.each do |v|
            batch_api.get_object("#{v.attachment}?fields=length") if v.attachment
          end
        end
        ActiveRecord::Base.transaction do
          video_infos.each do |v_info|
            video = Video.find_by(attachment: v_info['id'])
            video.update_attribute(:duration, v_info['length']) if video
          end
        end
        views = @graph.batch do |batch_api|
          videos.each do |video|
            batch_api.get_connection(video.uid, '/insights/post_video_complete_views_organic')
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
  end
end