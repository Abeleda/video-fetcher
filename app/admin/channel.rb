ActiveAdmin.register Channel do

  menu priority: 2

  index do
    selectable_column
    id_column
    column :name
    column :url
    column() { |c| status_tag c.platform }
    column do |channel|
      link_to 'Videos', "/admin/videos?q%5Bchannel_id_eq%5D=#{channel.id}"
    end
    # column :frequency
    actions
  end

  filter :name
  filter :url
  filter :platform, as: :select, collection: Channel.platforms

  form do |f|
    f.inputs do
      f.input :partner
      f.input :name
      f.input :url
      f.input :platform, as: :select, collection: Channel.platforms.collect { |s| [s.first.humanize, s.first] }
      f.input :frequency
    end
    f.actions
  end

  permit_params :partner_id, :name, :url, :platform, :frequency

end
