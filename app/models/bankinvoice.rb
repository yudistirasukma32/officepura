class Bankinvoice < ActiveRecord::Base

	belongs_to :bankexpensegroup
	belongs_to :office
	belongs_to :user

	belongs_to :bankexpense

  # Setup accessible (or protected) attributes for your model
  	attr_accessible :verified, :deleted, :date, :description, :debitgroup_id, :creditgroup_id, :total, :office_id, :deleteuser_id, :money_in

  scope :active, lambda {where(:deleted => false)}

end