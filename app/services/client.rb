class Client
  attr_accessor :channels

  attr_reader :app_id
  attr_reader :app_secret

  def initialize(app_id, app_secret)
    @app_id = app_id
    @app_secret = app_secret
    @channels = []
    raise 'No credentials' unless app_id && app_secret
  end

  def start
    channels.each do |channel|
      fork { Updater::Channel.new(channel, {app_id: app_id, app_secret: app_secret}).start }
    end
    Process.waitall
  end

  def add_channel(channel)
    channels << channel
  end
end
