class Booking < ActiveRecord::Base

    belongs_to :vehicle
    belongs_to :office
    belongs_to :event
    belongs_to :user

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :date, :vehicle_id, :event_id, :office_id, :description, :user_id

	scope :active, lambda {where(:enabled => true, :deleted => false)}  					

end