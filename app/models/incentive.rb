class Incentive < ActiveRecord::Base

	belongs_to :invoice
	belongs_to :office
	belongs_to :user

	has_many :receiptincentives

	# Setup accessible (or protected) attributes for your model
	attr_accessible :invoice_id, :office_id, :quantity, :description, :total, :deleted, 
					:user_id, :deleteuser_id

	scope :active, lambda {where(:deleted => false)}
end
