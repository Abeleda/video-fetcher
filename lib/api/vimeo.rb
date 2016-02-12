module API
  class Vimeo
    include PrintJSON
    HOST = 'https://api.vimeo.com'

    def initialize(channel_id, per_page=25)
      @channel_id = channel_id
      @per_page = per_page
    end

    def get_videos
      response = nil
      before = Time.now
      if @next_page
        response = RestClient.get @next_page, {authorization: "bearer #{VIMEO_ACCESS_TOKEN}"}
      else
        response = RestClient.get "#{HOST}/channels/#{@channel_id}/videos?fields=uri,name,link,duration,created_time,
                                   modified_time,stats.plays,metadata.connections.comments.total,
                                   metadata.connections.likes.total&sort=date&per_page=#{@per_page}",
                                   {authorization: "bearer #{VIMEO_ACCESS_TOKEN}"}
      end
      puts "Request completed in #{Time.now - before} seconds."
      json = JSON.parse response.body
      save_json_to_file json, 'vimeo' if DEBUG
      json['paging']['next'] ? @next_page = "#{HOST}#{json['paging']['next']}" : @next_page = nil
      yield json if block_given?
      return !@next_page.nil?
    end

  end
end