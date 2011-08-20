ActiveAdmin.register Invoice do
  scope :all, :default => true
  scope :draft do |invoices|
    invoices.where(:status => Invoice::STATUS_DRAFT)
  end

  scope :sent do |invoices|
    invoices.where(:status => Invoice::STATUS_SENT)
  end
  
  scope :paid do |invoices|
    invoices.where(:status => Invoice::STATUS_PAID)
  end
  
  index do
    column :status do |invoice|
      status_tag invoice.status, invoice.status_tag
    end
    column :code do |invoice|
      link_to "##{invoice.code}", admin_invoice_path(invoice)
    end
    
    column :client
    
    column "Issued" do |invoice|
      due = if invoice.due_date
        " (due in #{distance_of_time_in_words Time.now, invoice.due_date})"
      else
        ""
      end
      
      "#{l invoice.created_at, :format => :short}" + due
    end
    column :total do |invoice|
      number_to_currency invoice.total
    end
    
    column do |invoice|
      link_to("Details", admin_invoice_path(invoice)) + " | " + \
      link_to("Edit", edit_admin_invoice_path(invoice)) + " | " + \
      link_to("Delete", admin_invoice_path(invoice), :method => :delete, :confirm => "Are you sure?")
    end
  end
  
  show :title => :code do
    panel "Invoice Details" do
      attributes_table_for invoice do
        row("Code") { invoice.code }
        row("Status") { status_tag invoice.status, invoice.status_tag }
        row("Issue Date") { invoice.created_at }
        row("Due Date") { invoice.due_date }
      end
    end
    
    panel "Items" do
      table_for invoice.items do |t|
        t.column("Qty.") { |item| number_with_delimiter item.quantity }
        t.column("Description") { |item| item.description }
        t.column("Per Unit") { |item| number_to_currency item.amount }
        t.column("Total") { |item| number_to_currency item.total}
        
        # Show the tax, discount, subtotal and total
        tr do
          2.times { td "" }
          td "Discount:", :style => "text-align:right; font-weight: bold;"
          td "#{number_with_delimiter(invoice.discount)}%"
        end
        
        tr do
          2.times { td "" }
          td "Sub-total:", :style => "text-align:right; font-weight: bold;"
          td "#{number_to_currency(invoice.subtotal)}%"
        end
        
        tr do
          2.times { td "" }
          td "Taxes:", :style => "text-align:right; font-weight: bold;"
          td "#{number_to_currency(invoice.taxes)} (#{number_with_delimiter(invoice.tax)}%)"
        end
        
        tr do
          2.times { td "" }
          td "Total:", :style => "text-align:right; font-weight: bold;"
          td "#{number_to_currency(invoice.total)}%", :style => "font-weight: bold;"
        end
      end
    end
    
    panel "Other" do
      attributes_table_for invoice do
        row("Terms") { simple_format invoice.terms }
        row("Notes") { simple_format invoice.notes }
      end
    end
  end
  
  sidebar "Bill To", :only => :show do
    attributes_table_for invoice.client do
      row("Name") { link_to invoice.client.name, admin_client_path(invoice.client) }
      row("Email") { mail_to invoice.client.email }
      row("Address") { invoice.client.address }
      row("Phone") { invoice.client.phone }
    end
  end
  
  sidebar "Total", :only => :show do
    h1 number_to_currency(invoice.total), :style => "text-align: center; margin-top: 20px"
  end
  
  form do |f|
    f.inputs "Client" do
      f.input :client
    end
    
    f.inputs "Items" do
      f.has_many :items do |i|
        i.input :_destroy, :as => :boolean, :label => "Delete this item" unless i.object.id.nil?
        i.input :quantity
        i.input :description
        i.input :amount
      end
    end
    
    f.inputs "Options" do
      f.input :code, :hint => "The invoice's code, should be incremental. Suggested code: #{Invoice.suggest_code}"
      f.input :status, :collection => Invoice.status_collection, :as => :radio
      f.input :due_date
      f.input :tax, :input_html => { :style => "width: 30px"}, :hint => "This should be a percentage, from 0 to 100 (without the % sign)"
      f.input :discount, :input_html => { :style => "width: 30px"}, :hint => "This should be a percentage, from 0 to 100 (without the % sign)"
    end
    
    f.inputs "Other Fields" do
      f.input :terms, :input_html => { :rows => 4 }, :label => "Terms & Conditions"
      f.input :notes, :input_html => { :rows => 4 }
    end
    
    f.buttons
  end
end
