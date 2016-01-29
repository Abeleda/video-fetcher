ActiveAdmin.register Partner do

  menu priority: 1

  permit_params :name, :login, :password

end
