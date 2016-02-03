require 'action_view/helpers/text_helper'
include ActionView::Helpers::TextHelper
module Scanner
  class Facebook
    def initialize(channel)
      @channel = channel
      oauth = Koala::Facebook::OAuth.new(FACEBOOK_APP_ID, FACEBOOK_APP_SECRET)
      token = oauth.get_app_access_token
      @graph = Koala::Facebook::API.new(token)
    end
    def scan
      @user = @graph.get_object "?id=#{@channel.url}"
      @shares = []
      output_hash = {
          videos: [],
          metadata: [],
          lengths: [],
          views: [],
          comments: [],
          shares: []
      }
      counter = 1
      @fetching = true
      while @graph_collection.nil? || @fetching
        puts "Fetching page number #{counter}."
        fetch_videos
        output_hash[:videos].concat @filtered_feed
        output_hash[:lengths].concat fetch_length
        counter += 1
      end
      yield output_hash
    end
    private
    def fetch_videos
      if @graph_collection.nil?
        @graph_collection = @graph.get_connection(@user['id'], '?fields=feed.limit(50){object_id,source,message,created_time,updated_time,id,type,properties,shares,likes.summary(true),comments.summary(true)}')
      else
        if @graph_collection.class == Koala::Facebook::API::GraphCollection
          @graph_collection = @graph_collection.next_page
        else
          url = Koala::Facebook::API::GraphCollection.parse_page_url(@graph_collection['feed']['paging']['next'])
          @graph_collection = @graph.get_page(url)
        end
      end
      @filtered_feed = []
      if @graph_collection.class == Koala::Facebook::API::GraphCollection
        data = @graph_collection.raw_response['data']
        data.each { |f|
          if f['type'] && f['type'] == 'video'
            @filtered_feed << f
          end
        }
        @fetching = false if @graph_collection == []
      else
        return if @graph_collection['data'] && @graph_collection['data'] == []
        data = @graph_collection['feed']['data']
        data.each { |f|
          if f['type'] && f['type'] == 'video'
            @filtered_feed << f
          end
        }
        @fetching = false if @graph_collection['data'] == []
      end
    end
    def fetch_length
      @graph.batch do |batch_api|
        @filtered_feed.each do |v|
          batch_api.get_object("#{v['object_id']}?fields=length") if v['object_id']
        end
      end
    end
    def fetch_views
      @graph.batch do |batch_api|
        @filtered_feed.each do |video|
          batch_api.get_connection(video['id'], '/insights/post_video_complete_views_organic')
        end
      end
    end
  end
end