class Comment < ActiveRecord::Base
  belongs_to :video
  validates :video_id, presence: true
  validates :content, presence: true
end
