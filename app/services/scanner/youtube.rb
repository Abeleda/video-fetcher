module Scanner
  class Youtube
    def initialize(channel)
      @channel = channel
    end

    def scan
      channel = Yt::Channel.new url: @channel.url
      # channel = Yt::Channel.new id: 'UCxO1tY8h1AhOz0T4ENwmpow'

      video_ids = channel.videos.map(&:id)
      video_ids.each_slice(50) do |v|
        videos = Yt::Collections::Videos.new.where(id: v.join(','), part: 'snippet,contentDetails,statistics')

        videos.each do |v|
          video_attr = {
            uid: v.id,
            title: v.title,
            published: v.published_at,
            duration: v.duration,
            url: "https://www.youtube.com/watch?v=#{v.id}"
          }

          metadata_attr = {
            likes: v.like_count,
            dislikes: v.dislike_count,
            views: v.view_count,
            comments: v.comment_count,
          }

          yield video_attr, metadata_attr if block_given?
        end
      end
    end
  end
end