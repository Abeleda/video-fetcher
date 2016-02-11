ActiveAdmin.register Metadata do

  menu priority: 4

  filter :video

  index do
    selectable_column
    id_column
    column :video_id do |metadata|
      link_to metadata.video.id, admin_video_path(metadata.video)
    end
    column :likes
    column :views
    column :dislikes
    column :shares
    column :comments
    column :created_at
    actions
  end

  actions :all, except: [:create, :new]


  permit_params :video_id, :likes, :views, :dislikes, :comments, :shares, :video_id

end
