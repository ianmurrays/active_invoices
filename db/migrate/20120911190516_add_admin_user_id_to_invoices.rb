class AddAdminUserIdToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :admin_user_id, :integer
  end
end
