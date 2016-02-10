require 'action_view/helpers/text_helper'
include ActionView::Helpers::TextHelper

# TO-DO:
# Save app access token to database

module Scanner
  class Facebook
    NUMBER_OF_OBJECTS_IN_REQUEST = 25 # Do not set this constant to more than 100
    BREAK_AFTER = 20
    SLEEP_TIME = 1
    SLEEP_INTERVAL = 5


    def initialize(channel, app_id, app_secret)
      @channel = channel
      # Koala.http_service.faraday_middleware = Proc.new do |builder|
      #   builder.use Faraday::Response::Logger
      #   Koala::HTTPService::DEFAULT_MIDDLEWARE.call(builder)
      # end

      oauth = Koala::Facebook::OAuth.new(app_id, app_secret)
      token = oauth.get_app_access_token
      @graph = Koala::Facebook::API.new(token)
      @user = @graph.get_object "?id=#{@channel.url}"
    end

    def scan
      counter = 1
      fetching = true
      while @graph_collection.nil? || fetching
        break if counter > BREAK_AFTER
        sleep SLEEP_TIME if counter % SLEEP_INTERVAL == 0
        videos, metadata, comments = [], [], {}

        puts "Fetching page number #{counter}."
        before = Time.now
        fetching = fetch_videos do |v, m, c|
          videos << v
          metadata << m
          comments[v[:uid]] = c

        end
        counter += 1
        time = Time.now - before
        yield videos, metadata, comments, time
      end
    end

    private

    def fetch_videos
      begin
        before = Time.now
        if @graph_collection.nil?
          @graph_collection = @graph.get_connection(@user['id'],
            "?fields=feed.limit(#{NUMBER_OF_OBJECTS_IN_REQUEST}){object_id,source,message,created_time,updated_time,id,type,properties,shares,likes.summary(true).limit(0),comments.summary(true).limit(10)}")
        else
          if @graph_collection.class == Koala::Facebook::API::GraphCollection
            @graph_collection = @graph_collection.next_page
          else
            url = Koala::Facebook::API::GraphCollection.parse_page_url(@graph_collection['feed']['paging']['next'])
            @graph_collection = @graph.get_page(url)
          end
        end
        puts "Fetch videos request: #{Time.now - before} seconds."
      rescue => exception
        puts exception
        puts exception.backtrace
        raise exception
      end

      data = (@graph_collection.class == Koala::Facebook::API::GraphCollection) ? \
        @graph_collection.raw_response['data'] : @graph_collection['feed']['data']

      return false if data == []

      data.each do |v|
        if v['type'] == 'video'
          video = get_video_hash(v)
          metadata = get_metadata_hash(v)
          comments = get_video_comments(v)
          yield video, metadata, comments
        end
      end

      return true
    end


    def get_video_hash(video)

      {
        title: truncate(video['message'], length: 140),
        published: video['created_time'],
        modified: video['updated_time'],
        url: video['source'],
        uid: video['id'],
        # channel_id: @channel.id,
        attachment: video['object_id'],
        duration: get_duration(video)
      }
    end

    def get_duration(video)
      if video['properties']
        video['properties'].each do |property|
          if property['name'] == 'Length'
            return parse_video_duration property['text']
          end
        end
      end
      nil
    end

    def parse_video_duration(string)
      values = string.split(':')
      if values.length == 1
        values[0].to_i
      elsif values.length == 2
        minutes = values[0].to_i
        seconds = values[1].to_i
        minutes * 60 + seconds
      elsif values.length == 3
        hours = values[0].to_i
        minutes = values[1].to_i
        seconds = values[2].to_i
        hours * 60 * 60 + minutes * 60 + seconds
      else
        days = values[0].to_i
        hours = values[1].to_i
        minutes = values[2].to_i
        seconds = values[3].to_i
        days * 24 * 60 * 60 + hours * 60 * 60 + minutes * 60 + seconds
      end
    end

    def get_metadata_hash(video)
      metadata = {
        likes: video['likes']['summary']['total_count'],
        comments: video['comments']['summary']['total_count']
      }
      metadata[:shares] = video['shares']['count'] if video['shares']
      metadata
    end

    def get_video_comments(video)
      comments = []
      video['comments']['data'].each { |comment| comments << {content: comment['message']} }
      comments
    end

    def print_stats(hash)
      puts "\nStatistics:\n\nMin: #{hash[:min]} seconds.\nAverage: #{hash[:average]} seconds.\nMax: #{hash[:max]}." if hash
    end

    def get_stats(data)
      return nil if data.count == 0
      sum = 0
      data.each {|t| sum += t}
      average = sum / data.count
      {
        min: data.min,
        average: average,
        max: data.max
      }
    end
  end

end