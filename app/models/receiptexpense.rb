class Receiptexpense < ActiveRecord::Base

	belongs_to :officeexpense
	belongs_to :officeexpensegroup
	belongs_to :user

	attr_accessible :officeexpense_id, :total, :officeexpensegroup_id, :expensetype, :deleted, :user_id, :deleteuser_id

	scope :active, lambda {where(:deleted => false)}
end