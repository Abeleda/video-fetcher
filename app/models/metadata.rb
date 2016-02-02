class Metadata < ActiveRecord::Base
  belongs_to :video
  validates :video_id, presence: true
  validates :likes, presence: true
end
