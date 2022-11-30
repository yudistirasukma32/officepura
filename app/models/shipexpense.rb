class Shipexpense < ActiveRecord::Base

	belongs_to :officeexpensegroup
	belongs_to :bankexpensegroup
	belongs_to :routeship
	belongs_to :invoice
	belongs_to :user

	has_many :receiptships

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :date, :routeship_id, :invoice_id,
	:description, :user_id, :total, :officeexpensegroup_id, :bankexpensegroup_id, :expensetype,
	:gst_percentage, :gst_tax, :price_per, :misc_total

	scope :active, lambda {where(:enabled => true, :deleted => false)}

end