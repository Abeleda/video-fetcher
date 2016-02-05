module Updater
  class Channel

    def initialize(channel)
      @channel = channel
    end

    def start
      if @channel.youtube?
        Scanner::Youtube.new(@channel).scan do |video_attr, metadata_attr|
          ActiveRecord::Base.transaction do
            video = find_or_create_video(video_attr)
            video.metadata.create(metadata_attr)
          end
        end

      elsif @channel.facebook?
        Scanner::Facebook.new(@channel).scan do |videos, meta, comments|
          ActiveRecord::Base.transaction do
            videos.each_with_index do |v, i|
              m = meta[i]
              video = find_or_create_video(v)
              video.metadata.create! m
              find_or_create_comments(video, comments[video.uid])
            end
          end
        end
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

    def find_or_create_comments(video, comments)
      comments.each do |c|
        begin
          video.comments.find_or_create_by(c)
        rescue
          puts 'ERROR: INVALID CONTENT'
        end
      end
    end

end