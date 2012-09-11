class Item < ActiveRecord::Base
  belongs_to :invoice
  
  validates :quantity, :presence => true, :numericality => { :integer => true }
  validates :amount, :presence => true, :numericality => true
  validates :description, :presence => true

  attr_accessible :quantity, :description, :amount
  
  def total
    self.quantity * self.amount
  end
end
