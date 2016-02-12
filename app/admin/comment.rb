ActiveAdmin.register Comment, as: 'VideoComment' do

  menu priority: 5

  index do
    column :id
    column :video_id do |comment|
      link_to comment.video.id, admin_video_path(comment.video)
    end
    column :content
    actions
  end

  filter :video

  actions :all, except: [:create, :new]

end
