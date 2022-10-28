class Port < ActiveRecord::Base

  has_many :invoices

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :city, :address

  scope :active, lambda {where(:deleted => false)}

end
