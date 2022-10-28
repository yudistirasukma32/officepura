class Allowance < ActiveRecord::Base

	belongs_to :route
	belongs_to :vehiclegroup

  # Setup accessible (or protected) attributes for your model
  attr_accessible :route_id, :vehiclegroup_id, :driver_trip, :gas_trip, :deleted, :misc_allowance, :helper_trip, :train_trip

  scope :active, lambda {where(:deleted => false)}

end
