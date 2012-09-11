class AddAdminUserIdToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :admin_user_id, :integer
  end
end
