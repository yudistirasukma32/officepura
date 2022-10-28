class Officeexpense < ActiveRecord::Base

	belongs_to :officeexpensegroup
	belongs_to :vehicle
	belongs_to :office
	belongs_to :bankexpense
    belongs_to :isotank
    belongs_to :container

	has_many :receiptexpenses

  	# Setup accessible (or protected) attributes for your model
  	attr_accessible :enabled, :deleted, :date, :expensetype, :description, :vehicle_id, :officeexpensegroup_id, :total, :office_id, :deleteuser_id, :bankexpensegroup_id, :container_id, :isotank_id

  	scope :active, lambda {where(:enabled => true, :deleted => false)}

end
