# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


def create_admin
  ActiveRecord::Base.transaction do
    AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
  end
end

def create_partners
  ActiveRecord::Base.transaction do
    Partner.create!(name: 'Foobar', login: 'Foobar', password: 'Foobar')
  end
  Partner.first
end

def create_channels(partner_id)
  ActiveRecord::Base.transaction do

    # Youtube

    Channel.create!(name: 'PlayStation', url: 'https://www.youtube.com/user/PlayStation', platform: :youtube, partner_id: partner_id)
    Channel.create!(name: 'IGN', url: 'https://www.youtube.com/user/IGNentertainment', platform: :youtube, partner_id: partner_id)
    Channel.create!(name: 'Bethesda', url: 'https://www.youtube.com/user/BethesdaSoftworks', platform: :youtube, partner_id: partner_id)
    Channel.create!(name: 'Rockstar Games', url: 'https://www.youtube.com/user/RockstarGames', platform: :youtube, partner_id: partner_id)
    Channel.create!(name: 'Blizzard Entertainment', url: 'https://www.youtube.com/user/blizzard', platform: :youtube, partner_id: partner_id)

    Channel.create!(name: 'Apple', url: 'https://www.youtube.com/user/Apple', platform: :youtube, partner_id: partner_id)
    Channel.create!(name: 'Samsung Mobile', url: 'https://www.youtube.com/user/SamsungMobile', platform: :youtube, partner_id: partner_id)
    Channel.create!(name: 'Microsoft', url: 'https://www.youtube.com/user/Microsoft', platform: :youtube, partner_id: partner_id)
    Channel.create!(name: 'Apple', url: 'https://www.youtube.com/user/Google', platform: :youtube, partner_id: partner_id)
    Channel.create!(name: 'Android', url: 'https://www.youtube.com/user/GoogleMobile', platform: :youtube, partner_id: partner_id)

    # Facebook

    Channel.create!(name: 'AppStore', url: 'https://www.facebook.com/AppStore', platform: :facebook, partner_id: partner_id)
    Channel.create!(name: 'Nike', url: 'https://www.facebook.com/nike', platform: :facebook, partner_id: partner_id)
    Channel.create!(name: 'Nike Football', url: 'https://www.facebook.com/nikefootball/', platform: :facebook, partner_id: partner_id)
    Channel.create!(name: 'IGN', url: 'https://www.facebook.com/ign', platform: :facebook, partner_id: partner_id)
    Channel.create!(name: 'Google', url: 'https://www.facebook.com/Google/', platform: :facebook, partner_id: partner_id)

    Channel.create!(name: 'Microsoft', url: 'https://www.facebook.com/Microsoft', platform: :facebook, partner_id: partner_id)
    Channel.create!(name: 'Samsung Mobile', url: 'https://www.facebook.com/SamsungMobile', platform: :facebook, partner_id: partner_id)
    Channel.create!(name: 'ASUS', url: 'https://www.facebook.com/ASUS', platform: :facebook, partner_id: partner_id)
    Channel.create!(name: 'PlayStation', url: 'https://www.facebook.com/PlayStation', platform: :facebook, partner_id: partner_id)
    Channel.create!(name: 'Xbox', url: 'https://www.facebook.com/xbox', platform: :facebook, partner_id: partner_id)

    # Vimeo

    Channel.create!(name: 'Documentary Film', url: 'https://vimeo.com/channels/documentaryfilm', platform: :vimeo, partner_id: partner_id)
  end
end

create_admin
partner = create_partners
create_channels partner.id

