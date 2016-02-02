class Like < ActiveRecord::Base
  belongs_to :video
  validates :video_id, presence: true
  validates :amount, presence: true
end
