class Client < ActiveRecord::Base
  has_many :invoices, :dependent => :destroy
  belongs_to :organization
  belongs_to :admin_user
  
  validates :name, :presence => true
  validates :email, :format => { :with => /^(.+@.+\..+)?$/, :message => "is not a valid email address." }

  attr_accessible :name, :address, :phone, :email, :organization_id
end
