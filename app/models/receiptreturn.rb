class Receiptreturn < ActiveRecord::Base

	belongs_to :invoice
	belongs_to :office
	belongs_to :user
	belongs_to :invoicereturn
 
 	# Setup accessible (or protected) attributes for your model
  	attr_accessible :invoice_id, :office_id, :quantity, :driver_allowance, :gas_allowance, :description, :total, :deleted, :user_id, :helper_allowance, :deleteuser_id, :premi_allowance

  	scope :active, lambda {where(:deleted => false)}
end
