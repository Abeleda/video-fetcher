module Vimeo
  class Channel
    def initialize(channel,per_page=25)
      @channel = channel
      @per_page = per_page
    end

    def get_videos
      channel_id = @channel.url.split('/').last
      response = nil
      before = Time.now
      if @next_page
        response = RestClient.get @next_page
      else
        response = RestClient.get "https://api.vimeo.com/channels/#{channel_id}/videos?fields=uri,name,link,duration,created_time,modified_time,stats.plays,metadata.connections.comments.total,metadata.connections.likes.total&sort=date&per_page=#{@per_page}", {authorization: "bearer #{VIMEO_ACCESS_TOKEN}"}
      end
      puts "Request completed in #{Time.now - before} seconds."
      json = JSON.parse response.body
      Service::PrintJSON.save_json_to_file json, 'vimeo' if DEBUG
      @next_page = json['paging']['next']
      yield json if block_given?
      !@next_page.nil?
    end

  end
end