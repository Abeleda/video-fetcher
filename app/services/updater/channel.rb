module Updater
  class Channel
    include PrintJSON

    attr_reader :app_id, :app_secret, :channel

    def initialize(channel, credentials={})
      @channel = channel
      @app_id = credentials[:app_id] || FACEBOOK_APPS.first.try(:[], :app_id)
      @app_secret = credentials[:app_secret] || FACEBOOK_APPS.first.try(:[], :app_secret)
      raise 'No Facebook API credentials' unless app_id && app_secret
      ActiveRecord::Base.logger = nil
    end

    def start
      if channel.youtube?

        Scanner::Youtube.new(channel).scan do |video_attr, metadata_attr|
          ActiveRecord::Base.transaction do
            video = find_or_create_video(video_attr)
            video.metadata.create(metadata_attr)
          end
        end

      elsif channel.facebook?

        Scanner::Facebook.new(channel, app_id, app_secret).scan do |options|

          videos   = options[:videos]
          meta     = options[:meta]
          comments = options[:comments]
          times    = options[:times]

          if DEBUG
            save_json_to_file videos, 'videos'
            save_json_to_file meta, 'meta'
          end

          ActiveRecord::Base.transaction do
            videos.each_with_index do |v, i|
              m     = meta[i]
              video = find_or_create_video(v)
              video.metadata.create! m
              find_or_create_comments(video, comments[video.uid])
            end
          end

          yield times if block_given?
        end
      elsif channel.vimeo?

        Scanner::Vimeo.new(channel).scan do |videos, metadata|
          ActiveRecord::Base.transaction do
            videos.each_with_index do |v, i|
              m     = metadata[i]
              video = find_or_create_video v
              video.metadata.create! m
            end
          end
        end
      end
    end

  private

    def find_or_create_video(video_attr)
      puts "Video published at #{video_attr[:published]}"
      if channel.videos.exists?(uid: video_attr[:uid])
        Video.find_by(uid: video_attr[:uid])
      else
        begin
          channel.videos.create!(video_attr)
        rescue
          video_attr[:title] = 'Unprocessable title.'
          channel.videos.create!(video_attr)
        end
      end
    end

    def find_or_create_comments(video, comments)
      comments.each { |c| video.comments.find_or_create_by(c) }
    rescue
      # puts 'ERROR: INVALID CONTENT'
    end
  end
end
