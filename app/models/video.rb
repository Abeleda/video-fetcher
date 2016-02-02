class Video < ActiveRecord::Base

  belongs_to :channel

  validates :title, presence: true
  validates :published, presence: true
  validates :uid, presence: true, uniqueness: true
  validates :url, presence: true
  # validates :modified, presence: true
  # validates :duration, presence: true

end
