class Client < ActiveRecord::Base
  has_many :invoices, :dependent => :destroy
  
  validates :name, :presence => true
  validates :email, :format => { :with => /^(.+@.+\..+)?$/, :message => "is not a valid email address." }
end
