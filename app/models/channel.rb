class Channel < ActiveRecord::Base

  belongs_to :partner
  has_many :videos

  validates :partner_id, presence: true
  validates :name, presence: true
  validates :url, presence: true
  validates :platform, presence: true

end
