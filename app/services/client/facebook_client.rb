module Client
  class FacebookClient
    attr_accessor :channels
    def initialize(app_id, app_secret)
      @app_id = app_id
      @app_secret = app_secret
      @channels = []
      raise 'No credentials' unless @app_id && @app_secret
    end

    def start
      @channels.each do |channel|
        fork do
          Updater::Channel.new(channel, @app_id, @app_secret).start

        end
      end
      Process.waitall
    end

    def add_channel(channel)
      @channels << channel
    end
  end
end
