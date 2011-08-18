class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :quantity
      t.float :amount
      t.string :description
      t.integer :invoice_id

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
