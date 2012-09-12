ActiveAdmin.register Organization do
  index do
    column :name
    column :business_phone
    default_actions
  end
  
  filter :name

  form do |f|
    f.inputs "Client" do
      f.input :name
      f.input :street_1
      f.input :street_2
      f.input :city
      f.input :state
      f.input :country
      f.input :zip_code
      f.input :business_phone
      f.input :fax
    end
    f.buttons
  end

end
