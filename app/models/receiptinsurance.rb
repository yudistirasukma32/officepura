class Receiptinsurance < ActiveRecord::Base

	belongs_to :officeexpensegroup
	belongs_to :insuranceexpense
	belongs_to :user

  	# Setup accessible (or protected) attributes for your model
  	attr_accessible :date, :insuranceexpense_id, :total, :description, :user_id, 
	:deleted, :enabled, :officeexpensegroup_id, :bankexpensegroup_id, :expensetype, 
	:tsi_total, :insurance_rate

  	scope :active, lambda {where(:deleted => false)}

end
