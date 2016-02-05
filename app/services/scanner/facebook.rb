require 'action_view/helpers/text_helper'
include ActionView::Helpers::TextHelper
module Scanner
  class Facebook

    def initialize(channel)
      @channel = channel
      Koala.http_service.faraday_middleware = Proc.new do |builder|

        # Add Faraday's logger (which outputs to your console)

        builder.use Faraday::Response::Logger

        # Add the default middleware by calling the default Proc that we just replaced
        # SOURCE CODE: https://github.com/arsduo/koala/blob/master/lib/koala/http_service.rb#L20

        Koala::HTTPService::DEFAULT_MIDDLEWARE.call(builder)

      end
      oauth = Koala::Facebook::OAuth.new(FACEBOOK_APP_ID, FACEBOOK_APP_SECRET)
      token = oauth.get_app_access_token
      @graph = Koala::Facebook::API.new(token)
    end

    def scan
      @user = @graph.get_object "?id=#{@channel.url}"
      @output_videos = []
      @output_metadata = []
      @output_comments = Hash.new
      lengths = []
      counter = 1
      @fetching = true
      while @graph_collection.nil? || @fetching
        break if counter > 5
        puts "Fetching page number #{counter}."
        fetch_videos
        @output_videos.concat @videos
        @output_metadata.concat @metadatas
        lengths.concat fetch_length
        counter += 1
      end
      lengths.each do |l|

        video = @output_videos.select {|v| v[:attachment] == l['id']}
        video.each {|v| v[:duration] = l['length']}
      end
      yield @output_videos, @output_metadata, @output_comments
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
      @videos = []
      @metadatas = []
      if @graph_collection.class == Koala::Facebook::API::GraphCollection
        data = @graph_collection.raw_response['data']
        data.each { |f|
          if f['type'] && f['type'] == 'video'
            form_video_hash f
          end
        }
        @fetching = false if @graph_collection == []
      else
        return if @graph_collection['data'] && @graph_collection['data'] == []
        data = @graph_collection['feed']['data']
        data.each { |f|
          if f['type'] && f['type'] == 'video'
            form_video_hash f
          end
        }
        @fetching = false if @graph_collection['data'] == []
      end
    end

    def fetch_length
      @graph.batch do |batch_api|
        @videos.each do |v|
          batch_api.get_object("#{v[:attachment]}?fields=length") if v[:attachment]
        end
      end
    end

    def form_video_hash(video)
      hash = {
          title: truncate(video['message'], length: 140),
          published: video['created_time'],
          modified: video['updated_time'],
          url: video['source'],
          uid: video['id'],
          channel_id: @channel.id,
          attachment: video['object_id']
      }
      @videos << hash
      shares = video['shares']['count'] if video['shares']
      metadata = {
          likes: video['likes']['summary']['total_count'],
          comments: video['comments']['summary']['total_count'],
          shares: shares
      }
      @metadatas << metadata
      @output_comments[video['id']] = []
      video['comments']['data'].each { |comment| @output_comments[video['id']] << {content: comment['message']} }

    end


  end
end