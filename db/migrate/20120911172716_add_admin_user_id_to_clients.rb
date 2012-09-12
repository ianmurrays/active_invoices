class AddAdminUserIdToClients < ActiveRecord::Migration
  def change
    add_column :clients, :admin_user_id, :integer
  end
end
