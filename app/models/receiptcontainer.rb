class Receiptcontainer < ActiveRecord::Base

	belongs_to :officeexpensegroup
	belongs_to :containerexpense
	belongs_to :user

  	# Setup accessible (or protected) attributes for your model
  	attr_accessible :date, :containerexpense_id, :total, :description, :user_id, 
	:deleted, :enabled, :officeexpensegroup_id, :bankexpensegroup_id, :expensetype, 
	:gst_percentage, :gst_tax, :price_per

  	scope :active, lambda {where(:deleted => false)}

end
