class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :street_1
      t.string :street_2
      t.string :city
      t.string :state
      t.string :country
      t.string :zip_code
      t.string :business_phone
      t.string :fax

      t.timestamps
    end
  end
end
