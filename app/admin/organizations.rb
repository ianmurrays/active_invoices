ActiveAdmin.register Organization do
  index do
    column :name
    column :business_phone
    default_actions
  end
  
  filter :name
end
