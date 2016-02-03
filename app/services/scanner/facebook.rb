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
      user = @graph.get_object "?id=#{@channel.url}"
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
      while @graph_collection.nil? || @graph_collection != []
        puts "Fetching page number #{counter}."
        fetch_videos
        output_hash[:videos].concat @filtered_feed
        output_hash[:metadata].concat fetch_metadata
        output_hash[:shares].concat @shares
        output_hash[:lengths].concat fetch_length
        output_hash[:views].concat fetch_views
        output_hash[:comments].concat fetch_comments
        counter += 1
      end
      yield output_hash
    end

    private
    def fetch_videos
      if @graph_collection.nil?
        @graph_collection = @graph.get_connection(user['id'], 'feed/?fields=object_id,source,message,created_time,updated_time,id,type,properties,shares', limit: 50)
      else
        @graph_collection = @graph_collection.next_page
      end
      @filtered_feed = []
      @graph_collection.each { |f|
        if f['type'] && f['type'] == 'video'
          @filtered_feed << f
          if f['shares'] && f['shares']['count']
            @shares << f['shares']['count']
          else
            @shares << 0
          end
        end
      }
    end
    def fetch_metadata
      @graph.batch do |batch_api|
        @filtered_feed.each do |video|
          batch_api.get_connection(video['id'], 'likes?summary=true', limit: 50)
        end
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
    def fetch_comments
      @graph.batch do |batch_api|
        @filtered_feed.each do |video|
          batch_api.get_connection(video['id'], 'comments?summary=true', limit: 50)
        end
      end
    end
  end
end