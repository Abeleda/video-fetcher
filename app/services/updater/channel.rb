module Updater
  class Channel
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
        Scanner::Facebook.new(@channel).scan do |data|
          puts data[:videos]
          videos = []
          ActiveRecord::Base.transaction do
            data[:videos].each do |f|

              v = Video.find_by(uid: f['id'])
              if v
              else
                message = truncate(f['message'], length: 250)
                v = Video.create!(title: message, url: f['source'], published: f['created_time'], modified: f['updated_time'], uid: f['id'], channel_id: @channel.id, attachment: f['object_id'])
              end
              videos << v
            end
          end
          metadatas = []
          ActiveRecord::Base.transaction do
            (0...data[:metadata].count).each do |i|
              metadatas << Metadata.create!(likes: data[:metadata][i].raw_response['summary']['total_count'], video_id: videos[i].id, shares: data[:shares][i])
            end
          end
          ActiveRecord::Base.transaction do
            data[:lengths].each do |v_length|
              video = Video.find_by(attachment: v_length['id'])
              video.update_attribute(:duration, v_length['length']) if video
            end
          end
          ActiveRecord::Base.transaction do
            (0...data[:comments].count).each do |i|
              metadatas[i].update_attribute(:comments, data[:comments][i].raw_response['summary']['total_count'])
              video = videos[i]
              data[:comments][i].each do |comment|
                begin
                  c = Comment.find_or_create_by!(uid: comment['id'], content: comment['message'], video_id: video.id)
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
end