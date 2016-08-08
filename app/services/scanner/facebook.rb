require 'action_view/helpers/text_helper'
include ActionView::Helpers::TextHelper

module Scanner
  class Facebook
    include PrintJSON

    NUMBER_OF_OBJECTS_IN_REQUEST = 25 # Do not set this constant to more than 100
    BREAK_AFTER = 10
    SLEEP_TIME = 1
    BIG_BREAK = 10
    BIG_INTERVAL = 50
    SLEEP_INTERVAL = 5

    def initialize(channel, app_id, app_secret)
      @channel = channel

      if DEBUG
        Koala.http_service.faraday_middleware = Proc.new do |builder|
          builder.use Faraday::Response::Logger
          Koala::HTTPService::DEFAULT_MIDDLEWARE.call(builder)
        end
      end

      oauth = Koala::Facebook::OAuth.new(app_id, app_secret)
      token = oauth.get_app_access_token

      @graph = Koala::Facebook::API.new(token)
      @user  = @graph.get_object "?id=#{@channel.url}"
    end

    def scan
      counter  = 1
      fetching = true

      while @graph_collection.nil? || fetching

        break if counter > BREAK_AFTER # Break if number of fetched pages exceeds the limit

        # Required to bypass Facebook's API calls amount restrictions
        sleep(counter)

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

        yield videos: videos, meta: metadata, comments: comments, time: time
      end
    end

    private

    def fetch_videos
      data = data_from_facebook

      return false unless data

      data.each do |v|
        if v['type'] == 'video'
          video    = get_video_hash(v)
          metadata = get_metadata_hash(v)
          comments = get_video_comments(v)
          yield video, metadata, comments
        end
      end

      true
    end

    def data_from_facebook
      before = Time.now
      if @graph_collection.nil?
        init_graph_collection
      else
        next_page
      end

      puts "Fetch videos request: #{Time.now - before} seconds."

      return nil if @graph_collection == []
      data = graph_collection_data

      save_json_to_file data, 'facebook' if DEBUG
      data
    end

    def init_graph_collection
      @graph_collection = @graph.get_connection(@user['id'], "?fields=feed.limit(#{NUMBER_OF_OBJECTS_IN_REQUEST})
                                                                {object_id,source,message,created_time,updated_time,
                                                                id,type,properties,shares,likes.summary(true).limit(0),
                                                                comments.summary(true).limit(10)}")
    end

    def next_page
      @graph_collection = if @graph_collection.class == Koala::Facebook::API::GraphCollection
                            @graph_collection.next_page
                          else
                            url = Koala::Facebook::API::GraphCollection.parse_page_url(@graph_collection['feed']['paging']['next'])
                            @graph.get_page(url)
                          end
    end

    def graph_collection_data
      if @graph_collection.class == Koala::Facebook::API::GraphCollection
        @graph_collection.raw_response['data']
      else
        @graph_collection['feed']['data']
      end
    end

    def get_video_hash(video)
      {
        title:      truncate(video['message'], length: 140),
        published:  video['created_time'],
        modified:   video['updated_time'],
        url:        video['source'],
        uid:        video['id'],
        attachment: video['object_id'],
        duration:   duration(video)
      }
    end

    def duration(video)
      return unless video['properties']

      video['properties'].each do |property|
        return parse_video_duration property['text'] if property['name'] == 'Length'
      end

      nil
    end

    def parse_video_duration(string)
      values     = string.split(':')
      times      = OpenStruct.new
      time_units = [:seconds, :minutes, :hours, :days]
      values.reverse.each_with_index { |value, index| times[time_units[index]] = value }

      times.seconds.to_i + times.minutes.to_i * 60 + times.hours.to_i * 60 * 60 + times.days.to_i * 60 * 60 * 24
    end

    def get_metadata_hash(video)
      metadata = {
        likes:    video['likes']['summary']['total_count'],
        comments: video['comments']['summary']['total_count']
      }
      metadata[:shares] = video['shares']['count'] if video['shares']
      metadata
    end

    def get_video_comments(video)
      comments = []
      video['comments']['data'].each { |comment| comments << { content: comment['message'] } }
      comments
    end

    def sleep(counter)
      Kernel.sleep SLEEP_TIME if counter % SLEEP_INTERVAL == 0

      if counter % BIG_INTERVAL == 0
        puts 'BIG BREAK'
        Kernel.sleep BIG_BREAK
      end
    end
  end
end