class Insuranceexpense < ActiveRecord::Base

	belongs_to :insurancevendor
	belongs_to :invoice
	belongs_to :user

	has_many :receiptinsurances

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :date, :invoice_id, :insurancevendor_id,
	:description, :user_id, :officeexpensegroup_id, :bankexpensegroup_id, :expensetype, 
	:tsi_total, :insurance_rate, :total,
	:policy_number, :insurance_name, :top_days, :due_date

	scope :active, lambda {where(:enabled => true, :deleted => false)}

end
