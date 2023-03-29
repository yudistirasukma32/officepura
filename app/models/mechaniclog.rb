class Mechaniclog < ActiveRecord::Base

	belongs_to :mechanic
	belongs_to :vehicle
	belongs_to :driver
	belongs_to :invoice
	belongs_to :user
	
	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :date, :invoice_id, :vehicle_id, :driver_id, :mechanic_id,
					:group, :description, :comment, :grade, :user_id, :deleteuser_id, :datetime_start, :datetime_end
	
	scope :active, lambda {where(:enabled => true, :deleted => false)}  					

end