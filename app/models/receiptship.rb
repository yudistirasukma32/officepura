class Receiptship < ActiveRecord::Base

	belongs_to :officeexpensegroup
	belongs_to :shipexpense
	belongs_to :user

  	# Setup accessible (or protected) attributes for your model
  	attr_accessible :date, :shipexpense_id, :total, :description, :user_id, 
	:deleted, :enabled, :officeexpensegroup_id, :bankexpensegroup_id, :expensetype, 
	:gst_percentage, :gst_tax, :misc_total

  	scope :active, lambda {where(:deleted => false)}

end
