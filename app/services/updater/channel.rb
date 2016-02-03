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
        # 1. Optimize hashes
        # 2. Refactor creating
        Scanner::Facebook.new(@channel).scan do |data|
          ActiveRecord::Base.transaction do
            data[:videos].each do |f|
              @v = Video.find_by(uid: f['id'])
              if @v
              else
                message = truncate(f['message'], length: 140)
                @v = Video.create!(title: message, url: f['source'], published: f['created_time'], modified: f['updated_time'], uid: f['id'], channel_id: @channel.id, attachment: f['object_id'])
              end
              likes = f['likes']['summary']['total_count']
              comments = f['comments']['summary']['total_count']
              shares = f['shares']['count'] if f['shares']
              @v.metadatas.create!(likes: likes, comments: comments, shares: shares)
              comments = f['comments']['data']
              comments.each do |comment|
                begin
                  @v.comments.create!(content: comment['message'])
                rescue
                  puts 'ERROR: INVALID MESSAGE'
                end
              end
            end
          end
          ActiveRecord::Base.transaction do
            data[:lengths].each do |v_length|
              video = Video.find_by(attachment: v_length['id'])
              video.update_attribute(:duration, v_length['length']) if video
            end
          end
        end
      end
    end
  end
end