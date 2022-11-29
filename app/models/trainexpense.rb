class Trainexpense < ActiveRecord::Base

	belongs_to :officeexpensegroup
	belongs_to :bankexpensegroup
	belongs_to :routetrain
	belongs_to :invoice
	belongs_to :user

	has_many :receipttrains

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :date, :routetrain_id, :invoice_id,
	:description, :user_id, :total, :officeexpensegroup_id, :bankexpensegroup_id, :expensetype, :gst_percentage, :gst_tax, :price_per

	scope :active, lambda {where(:enabled => true, :deleted => false)}

end
