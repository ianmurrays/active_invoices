include ActionView::Helpers::NumberHelper

def generate_invoice(invoice)
  # Generate invoice
  Prawn::Document.generate @invoice.invoice_location do |pdf|
    # Title
    pdf.text "Invoice ##{invoice.code}", :size => 25

    # Client info
    pdf.text invoice.client.name
    pdf.text invoice.client.address
    pdf.text invoice.client.phone

    #pdf.draw_text "#{t('.created_at')}: #{l(invoice.created_at, :format => :short)}", :at => [pdf.bounds.width / 2, pdf.bounds.height - 30]

    # Our company info
    # pdf.float do
    #   pdf.bounding_box [0, pdf.bounds.top - 5], :width => pdf.bounds.width do
    #     pdf.text invoice.client.company.name, :size => 20, :align => :right
    #   end
    # end

    pdf.move_down 20

    # Items
    header = ['Qty.', 'Description', 'Amount', 'Total']
    items = invoice.items.collect do |item|
      [item.quantity.to_s, item.description, number_to_currency(item.amount), number_to_currency(item.total)]
    end
    
    items = items + [["", "", "Discount:", "#{number_with_delimiter(invoice.discount)}%"]] \
                  + [["", "", "Sub-total:", "#{number_to_currency(invoice.subtotal)}"]] \
                  + [["", "", "Taxes:", "#{number_to_currency(invoice.taxes)} (#{number_with_delimiter(invoice.tax)}%)"]] \
                  + [["", "", "Total:", "#{number_to_currency(invoice.total)}"]]

    pdf.table [header] + items, :header => true, :width => pdf.bounds.width do
      row(-4..-1).borders = []
      row(-4..-1).column(2).align = :right
      row(0).style :font_style => :bold
      row(-1).style :font_style => :bold
    end
    
                     # :border_style => :grid, 
                     # :headers => header, 
                     # :width => pdf.bounds.width, 
                     # :row_colors => %w{cccccc eeeeee},
                     # :align => { 0 => :right, 1 => :left, 2 => :right, 3 => :right, 4 => :right }


    # Terms
    if invoice.terms != ''
      pdf.move_down 20
      pdf.text 'Terms', :size => 18
      pdf.text invoice.terms
    end

    # Notes
    if invoice.notes != ''
      pdf.move_down 20
      pdf.text 'Notes', :size => 18
      pdf.text invoice.notes
    end

    # Footer
    pdf.draw_text "Generated at #{l(Time.now, :format => :short)}", :at => [0, 0]
  end
end

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
  
  # -----------------------------------------------------------------------------------
  # PDF
  
  action_item :only => :show do
    link_to "Generate PDF", generate_pdf_admin_invoice_path(resource)
  end
  
  member_action :generate_pdf do
    @invoice = Invoice.find(params[:id])
    generate_invoice(@invoice)
    
    # Send file to user
    send_file @invoice.invoice_location
  end
  
  # -----------------------------------------------------------------------------------
  
  # -----------------------------------------------------------------------------------
  # Email sending
  
  action_item :only => :show do
    link_to "Send", send_invoice_admin_invoice_path(resource)
  end
  
  member_action :send_invoice do
    @invoice = Invoice.find(params[:id])
  end
  
  member_action :dispatch_invoice, :method => :post do
    @invoice = Invoice.find(params[:id])
    
    # Generate the PDF invoice if neccesary
    generate_invoice(@invoice) if params[:attach_pdf]
    
    # Attach our own email if we want to send a copy to ourselves.
    params[:recipients] += ", #{current_admin_user.email}" if params[:send_copy]
    
    # Send all emails
    params[:recipients].split(',').each do |recipient|
      InvoicesMailer.send_invoice(@invoice.id, recipient.strip, params[:subject], params[:message], !!params[:attach_pdf]).deliver
    end
    
    # Change invoice status to sent
    @invoice.status = Invoice::STATUS_SENT
    @invoice.save
    
    redirect_to admin_invoice_path(@invoice), :notice => "Invoice sent succesfully"
  end
  
  # -----------------------------------------------------------------------------------
  
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

  filter :client
  filter :code
  filter :due_date
  
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
      f.input :client, :collection => current_admin_user.clients
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
