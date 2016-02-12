class Channel < ActiveRecord::Base

  belongs_to :partner
  has_many :videos, dependent: :destroy

  enum platform: [:youtube, :facebook, :vimeo]

  validates :partner_id, presence: true
  validates :name, presence: true
  validates :url, presence: true
  validates :platform, presence: true

end
