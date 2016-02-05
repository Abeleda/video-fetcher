class Video < ActiveRecord::Base

  belongs_to :channel
  has_many :metadata

  validates :title, presence: true
  validates :published, presence: true
  # validates :modified, presence: true
  # validates :duration, presence: true

end
