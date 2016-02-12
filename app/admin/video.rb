ActiveAdmin.register Video do

  menu priority: 3

  filter :channel
  filter :title
  filter :channel_platform, as: :select, collection: Channel.platforms

  index do
    column :channel_id do |video|
      link_to video.channel.name, admin_channel_path(video.channel), target: '_blank'
    end
    column :title
    column :type do |video|
      status_tag video.channel.platform
    end
    column :duration
    column :url do |video|
      link_to video.url, video.url
    end
    column :published
    column do |video|
      link_to 'Metadata', "/admin/metadata?q%5Bvideo_id_eq%5D=#{video.id}"
      end
    column do |video|
      link_to 'Comments', "/admin/video_comments?q%5Bvideo_id_eq%5D=#{video.id}"
    end
    actions
  end

  actions :all, except: [:create, :new]

  permit_params :channel_id, :title, :published, :modified, :duration, :url, :uid, :attachment

end
