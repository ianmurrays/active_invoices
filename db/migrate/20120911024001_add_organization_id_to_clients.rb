class AddOrganizationIdToClients < ActiveRecord::Migration
  def change
    add_column :clients, :organization_id, :integer
  end
end
