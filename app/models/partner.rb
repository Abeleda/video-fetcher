class Partner < ActiveRecord::Base

  has_many :channels

  validates :name, presence: true
  validates :login, presence: true
  validates :password, presence: true

end
