ActiveAdmin.register AdminUser, :as => "Users" do
  filter :email
  filter :last_sign_in_at
  
  index do
    column :id
    column :email
    column "Last Sign in", :last_sign_in_at
    column do |user|
      delete = " | " + link_to("Delete", admin_user_path(user), :method => :delete, :confirm => "Are you sure?") unless current_admin_user == user
      
      link_to("Details", admin_user_path(user)) + " | " + \
      link_to("Edit", edit_admin_user_path(user)) + delete.try(:html_safe)
    end
  end
  
  show :title => :email do 
    panel "User Details" do
      attributes_table_for user, :email, :last_sign_in_at, :created_at
    end
  end
  
  form do |f|
    f.inputs do
      f.input :email
      f.input :password, :type => :password
      f.input :password_confirmation, :type => :password
    end
    
    f.buttons
  end
end
