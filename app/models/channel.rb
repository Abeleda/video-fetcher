class Channel < ActiveRecord::Base

  belongs_to :partner
  has_many :videos, dependent: :destroy

  enum platform: [:youtube, :facebook]

  validates :partner_id, presence: true
  validates :name, presence: true
  validates :url, presence: true
  validates :platform, presence: true

  # if (@channel.platform == :youtube)

end
