class Video < ActiveRecord::Base

  before_validation :set_default_values

  belongs_to :channel
  has_many :metadata, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :published, presence: true
  validates :uid, presence: true, uniqueness: true
  validates :url, presence: true

  private

  def set_default_values
    self.title ||= 'No title provided'
  end

end
