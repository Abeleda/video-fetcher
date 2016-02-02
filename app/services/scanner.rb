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

    end
  end

end