ActiveAdmin.register Metadata do

  menu priority: 4

  index do
    selectable_column
    id_column
    column :likes
    column :views
    column :dislikes
    column :shares
    column :comments
    column :created_at
    actions
  end

  permit_params :video_id, :likes, :views, :dislikes, :comments, :shares, :video_id

end
