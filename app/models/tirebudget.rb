class Tirebudget < ActiveRecord::Base

	belongs_to :vehicle
	belongs_to :productgroup

  # Setup accessible (or protected) attributes for your model
  attr_accessible :vehicle_id, :productgroup_id, :budget, :deleted

  scope :active, lambda {where(:deleted => false)}

end
