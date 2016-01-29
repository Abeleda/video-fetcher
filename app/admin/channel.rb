ActiveAdmin.register Channel do

  menu priority: 2

  permit_params :partner_id, :name, :url, :platform, :frequency

end
