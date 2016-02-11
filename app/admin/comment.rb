ActiveAdmin.register Comment, as: 'VideoComment' do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if resource.something?
#   permitted
# end
  menu priority: 5
  permit_params :video_id, :content

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
