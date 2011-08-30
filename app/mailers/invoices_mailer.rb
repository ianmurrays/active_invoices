class InvoicesMailer < ActionMailer::Base
  default :from => Rails.configuration.sender
  
  def send_invoice(invoice_id, to, subject, message, attach_pdf)
    @invoice = Invoice.find(invoice_id)
    @message = message
    attachments["invoice-#{@invoice.code}.pdf"] = File.read(@invoice.invoice_location) if attach_pdf
    
    mail(:to => to,
         :subject => subject)
  end
end
