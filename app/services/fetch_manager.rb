class FetchManager
  def initialize(channels)
    @clients = []
    FACEBOOK_APPS.each do |app|
      @clients << Client::FacebookClient.new(app[:app_id], app[:app_secret])
    end
    facebook_channels = channels.select {|c| c.platform == 'facebook'}

    facebook_channels.each_with_index do |channel, index|
      index_of_client = index % @clients.length
      @clients[index_of_client].add_channel channel
    end


  end

  def scan
    @clients.each do |client|
      fork do
        client.start
      end
    end
    Process.waitall
  end
end