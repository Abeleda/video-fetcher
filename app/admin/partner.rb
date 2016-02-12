ActiveAdmin.register Partner do

  menu priority: 1

  filter :name
  filter :login

  index do
    id_column
    column :active
    column :name
    column :login
    column :password
    column :created_at
    column do |partner|
      link_to 'Channels', "/admin/channels?q%5Bpartner_id_eq%5D=#{partner.id}"
    end
  end

  permit_params :name, :login, :password

end
