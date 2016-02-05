require 'action_view/helpers/text_helper'
include ActionView::Helpers::TextHelper
module Scanner
  class Facebook

    def initialize(channel)
      @channel = channel
      Koala.http_service.faraday_middleware = Proc.new do |builder|
        builder.use Faraday::Response::Logger
        Koala::HTTPService::DEFAULT_MIDDLEWARE.call(builder)
      end
      oauth = Koala::Facebook::OAuth.new(FACEBOOK_APP_ID, FACEBOOK_APP_SECRET)
      token = oauth.get_app_access_token
      @graph = Koala::Facebook::API.new(token)
    end

    def scan
      @user = @graph.get_object "?id=#{@channel.url}"
      output_videos = []
      output_metadata = []
      output_comments = Hash.new
      lengths = []
      counter = 1
      fetching = true
      while @graph_collection.nil? || fetching
        # break if counter > 3
        puts "Fetching page number #{counter}."
        videos = []
        fetching = fetch_videos do |video, metadata, comments|
          videos << video
          output_metadata << metadata
          output_comments[video[:uid]] = comments
        end
        lengths.concat fetch_length videos
        output_videos.concat videos
        counter += 1
      end
      lengths.each do |l|
        video = output_videos.select {|v| v[:attachment] == l['id']}
        video.each {|v| v[:duration] = l['length']}
      end
      yield output_videos, output_metadata, output_comments
    end

    private

    def fetch_videos
      if @graph_collection.nil?
        @graph_collection = @graph.get_connection(@user['id'], '?fields=feed.limit(25){object_id,source,message,created_time,updated_time,id,type,properties,shares,likes.summary(true),comments.summary(true)}')
      else
        if @graph_collection.class == Koala::Facebook::API::GraphCollection
          @graph_collection = @graph_collection.next_page
        else
          url = Koala::Facebook::API::GraphCollection.parse_page_url(@graph_collection['feed']['paging']['next'])
          @graph_collection = @graph.get_page(url)
        end
      end
      data = (@graph_collection.class == Koala::Facebook::API::GraphCollection) ? @graph_collection.raw_response['data'] : @graph_collection['feed']['data']
      return false if data == []
      data.each do |v|
        if v['type'] == 'video'
          video = get_video_hash(v)
          metadata = get_metadata_hash(v)
          comments = get_video_comments v
          yield video, metadata, comments
        end
      end
      true
    end

    def fetch_length(videos)
      @graph.batch do |batch_api|
        videos.each { |v| batch_api.get_object("#{v[:attachment]}?fields=length") if v[:attachment] }
      end
    end

    def get_video_hash(video)
      {
          title: truncate(video['message'], length: 140),
          published: video['created_time'],
          modified: video['updated_time'],
          url: video['source'],
          uid: video['id'],
          channel_id: @channel.id,
          attachment: video['object_id']
      }
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
  end

end