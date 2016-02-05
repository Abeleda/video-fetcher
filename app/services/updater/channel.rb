module Updater
  class Channel

    def initialize(channel)
      @channel = channel
    end

    def start
      if @channel.youtube?
        scanner = Scanner::Youtube.new @channel

        ActiveRecord::Base.transaction do
          scanner.scan do |video_attr, metadata_attr|
            video = find_or_create_video(video_attr)
            video.metadata.create(metadata_attr)
          end
        end

      elsif @channel.facebook?


      end
    end

  private

    def find_or_create_video(video_attr)
      if @channel.videos.exists?(uid: video_attr[:uid])
        Video.find_by(uid: video_attr[:uid])
      else
        @channel.videos.create(video_attr)
      end
    end

  end
end