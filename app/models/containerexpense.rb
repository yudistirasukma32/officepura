class Containerexpense < ActiveRecord::Base

	belongs_to :officeexpensegroup
	belongs_to :bankexpensegroup
	belongs_to :container
	belongs_to :invoice
	belongs_to :user

	has_many :receiptcontainers

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :date, :invoice_id, :container_id,
	:description, :user_id, :total, :officeexpensegroup_id, :bankexpensegroup_id, :expensetype,
	:gst_percentage, :gst_tax, :price_per, :deleteuser_id

	scope :active, lambda {where(:enabled => true, :deleted => false)}

end