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
        Scanner::Facebook.new(@channel).scan do |videos, meta, comments|
          ActiveRecord::Base.transaction do
            videos.each_with_index do |v, i|
              m = meta[i]
              @video = Video.find_by(uid: v[:uid])
              @video = Video.create! v unless @video
              @video.metadatas.create! m
              video_comments = comments[@video.uid]
              video_comments.each do |c|
                begin
                  @video.comments.find_or_create_by!(c)
                rescue
                  puts 'ERROR: INVALID CONTENT'
                end
              end
            end
          end
        end

      end
    end

  end
end