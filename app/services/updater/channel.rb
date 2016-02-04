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
          ActiveRecord::Base.transaction do
            byebug
            (0...data[:videos].length).each do |i|
              v = data[:videos][i]
              m = data[:metadatas][i]
              @video = Video.find_by(uid: v[:uid])
              unless @v
                @video = Video.create! v
              end
              @video.metadatas.create! m

            end
          end
        end

      end
    end

  end
end