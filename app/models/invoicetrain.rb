class Invoicetrain < ActiveRecord::Base

	belongs_to :user
  belongs_to :isotank
  belongs_to :container
	belongs_to :station
	belongs_to :operator, class_name: "Operator"
  belongs_to :route

	# Setup accessible (or protected) attributes for your model
	attr_accessible :deleted, :enabled, :date, :code, :train_status, :operator_id, :station_id, 
	:container_type, :route_id, :container_type, :isotank_id, :isotank_number, :container_id, :container_number, :description, :user_id, :deleteuser_id, :total

	scope :active, lambda {where(:enabled => true,:deleted => false)}

end