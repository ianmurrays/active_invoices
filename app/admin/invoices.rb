ActiveAdmin.register Invoice do
  form do |f|
    f.inputs "Client" do
      f.input :client
    end
    
    f.inputs "Items" do
      f.has_many :items do |i|
        i.input :quantity
        i.input :description
        i.input :amount
      end
    end
    
    f.inputs "Options" do
      f.input :code, :hint => "The invoice's code, should be incremental. Suggested code supplied.", :input_html => {:value => Invoice.suggest_code}
      f.input :status, :collection => Invoice.status_collection, :as => :radio
      f.input :due_date
      f.input :tax, :input_html => { :style => "width: 20px", :value => "0"}, :hint => "This should be a percentage, from 0 to 100 (without the % sign)"
      f.input :discount, :input_html => { :style => "width: 20px", :value => "0"}, :hint => "This should be a percentage, from 0 to 100 (without the % sign)"
    end
    
    f.inputs "Other Fields" do
      f.input :terms, :input_html => { :rows => 4 }, :label => "Terms & Conditions"
      f.input :notes, :input_html => { :rows => 4 }
    end
    
    f.buttons
  end
end
