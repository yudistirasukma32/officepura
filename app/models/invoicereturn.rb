class Invoicereturn < ActiveRecord::Base

	belongs_to :invoice
	belongs_to :office
	belongs_to :user

	has_many :receiptreturns

  	# Setup accessible (or protected) attributes for your model
  	attr_accessible :invoice_id, :office_id, :date, :quantity, :driver_allowance, :gas_allowance, :gas_leftover, :description, :total, :deleted, :user_id, :helper_allowance, :deleteuser_id, :premi_allowance

  	def sum_gasleftover
  		self.gas_leftover * self.invoice.gas_cost
  	end

  	scope :active, lambda {where(:deleted => false)}

end
