class FetchManager

  attr_reader :clients

  def initialize(channels)
    @clients = []

    FACEBOOK_APPS.each { |app| clients << Client.new(app[:app_id], app[:app_secret]) }

    channels.each_with_index do |channel, index|
      index_of_client = index % clients.length
      clients[index_of_client].add_channel channel
    end
  end

  def scan
    clients.each do |client|
      fork { client.start }
    end
    Process.waitall
  end
end
