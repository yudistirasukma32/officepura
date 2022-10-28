class Bonusreceipt < ActiveRecord::Base

	belongs_to :invoice
	belongs_to :office
	belongs_to :user

	has_many :receiptpremis

	# Setup accessible (or protected) attributes for your model
	attr_accessible :invoice_id, :office_id, :quantity, :description, :total, :deleted, :load_location, :load_date, :load_hour, :unload_location, 
					:unload_date, :unload_hour, :user_id, :deleteuser_id

	scope :active, lambda {where(:deleted => false)}
end
