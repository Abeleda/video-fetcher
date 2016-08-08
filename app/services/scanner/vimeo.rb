require 'action_view/helpers/text_helper'
include ActionView::Helpers::TextHelper
module Scanner
  class Vimeo
    PER_PAGE = 50 # Do not set this more than 50
    BREAK_AFTER = 1000000

    def initialize(channel, number_of_pages=BREAK_AFTER)
      channel_id = channel.url[/[^\/]*\Z/]
      @channel   = API::Vimeo.new(channel_id, PER_PAGE)
    end

    def scan
      fetching = true
      counter = 0

      while fetching
        break if counter == BREAK_AFTER

        fetching = @channel.get_videos do |json|
          data     = json['data']
          videos   = []
          metadata = []

          data.each do |video|
            videos   << get_video_hash(video)
            metadata << get_metadata_hash(video)
          end

          yield videos, metadata if block_given?
        end
        counter += 1
      end
    end

  private
    def get_video_hash(video)
      {
        title:     truncate(video['name'], length: 140),
        published: video['created_time'],
        modified:  video['modified_time'],
        url:       video['link'],
        uid:       video['link'],
        duration:  video['duration']
      }
    end

    def get_metadata_hash(video)
      {
        likes:    video['metadata']['connections']['likes']['total'],
        comments: video['metadata']['connections']['comments']['total'],
        views:    video['stats']['plays']
      }
    end
  end
end