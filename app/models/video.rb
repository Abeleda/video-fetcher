class Video < ActiveRecord::Base
  has_many :metadatas
  belongs_to :channel
  has_many :comments
  validates :published, presence: true
  validates :uid, presence: true, uniqueness: true
  validates :url, presence: true
  # validates :modified, presence: true
  # validates :duration, presence: true
end
