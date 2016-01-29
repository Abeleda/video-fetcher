ActiveAdmin.register Channel do


  permit_params :partner_id, :name, :url, :platform, :frequency

end
