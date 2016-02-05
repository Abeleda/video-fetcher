ActiveAdmin.register Video do

  menu priority: 3

  permit_params :channel_id, :title, :published, :modified, :duration, :url, :uid, :attachment

end
