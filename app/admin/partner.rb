ActiveAdmin.register Partner do

  menu priority: 1

  filter :name
  filter :login

  permit_params :name, :login, :password

end
