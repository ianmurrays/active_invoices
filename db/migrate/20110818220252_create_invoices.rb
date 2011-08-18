class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.string :code
      t.text :notes
      t.text :terms
      t.string :status
      t.datetime :due_date
      t.float :tax
      t.float :discount
      t.integer :client_id

      t.timestamps
    end
  end

  def self.down
    drop_table :invoices
  end
end
