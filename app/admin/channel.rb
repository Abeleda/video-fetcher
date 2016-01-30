ActiveAdmin.register Channel do

  menu priority: 2

  index do
    selectable_column
    id_column
    column :name
    column :url
    column() { |c| status_tag c.platform }
    column :frequency
    actions
  end

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
