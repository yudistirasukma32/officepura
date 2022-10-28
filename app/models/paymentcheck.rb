class Paymentcheck < ActiveRecord::Base

  has_many :productorderitems
  belongs_to :supplier
	

  # Setup accessible (or protected) attributes for your model
  attr_accessible :deleted, :date, :check_no, :total, :supplier_id

  scope :active, lambda {where(:deleted => false)}  					

end