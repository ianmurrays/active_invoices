ActiveAdmin.register Client do
  filter :name
  filter :email
  filter :address
  filter :phone
  
  index do
    column :name
    column :email do |client|
      if client.email 
        mail_to client.email, client.email 
      else 
        "-"
      end
    end
    column :address do |client|
      truncate client.address
    end
    column :phone
    column do |client|
      link_to("Details", admin_client_path(client)) + " | " + \
      link_to("Edit", edit_admin_client_path(client)) + " | " + \
      link_to("Delete", admin_client_path(client), :method => :delete, :confirm => "Are you sure?")
    end
  end
  
  show :title => :name do
    panel "Client Details" do
      attributes_table_for client do
        row("Name") { client.name }
        row("Email") { mail_to client.email }
        row("Address") { client.address }
        row("Phone") { client.phone }
      end
    end
  end

  sidebar "Total Billed", :only => :show do
    h1 number_to_currency(Invoice.where(:client_id => client.id).all.sum(&:total)), :style => "text-align: center; margin-top: 20px;"
  end
  
  sidebar "Latest Invoices", :only => :show do
    table_for Invoice.where(:client_id => client.id).order('created_at desc').limit(5).all do |t|
      t.column("Status") { |invoice| status_tag invoice.status, invoice.status_tag }
      t.column("Code") { |invoice| link_to "##{invoice.code}", admin_invoice_path(invoice) }
      t.column("Total") { |invoice| number_to_currency invoice.total }
    end
  end
end
