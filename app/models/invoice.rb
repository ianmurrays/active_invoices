class Invoice < ActiveRecord::Base
  STATUS_DRAFT = 'draft'
  STATUS_SENT  = 'sent'
  STATUS_PAID  = 'paid'
  
  belongs_to :client
  has_many :items, :dependent => :destroy
  
  accepts_nested_attributes_for :items
  
  validates :code, :client_id, :presence => true
  validates :status, :inclusion => { :in => [STATUS_PAID, STATUS_SENT, STATUS_DRAFT], :message => "You need to pick one status." }
  validates :tax, :discount, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100 }
  
  def self.suggest_code
    invoice = order('created_at desc').limit(1).first
    if invoice
      "INV-#{invoice.id + 1}"
    else
      "INV-1"
    end
  end
  
  def self.status_collection
    {
      "Draft" => STATUS_DRAFT,
      "Sent" => STATUS_SENT,
      "Paid" => STATUS_PAID
    }
  end
end
