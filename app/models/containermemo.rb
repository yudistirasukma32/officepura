class Containermemo < ActiveRecord::Base

    belongs_to :container
	belongs_to :operator
	belongs_to :vendor

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :date, :container_type, :container_id, 
					:operator_id, :storage_day, :description, :container_fee, :additional_fee, :total,
					:vendor_id, :price_per
 
	scope :active, lambda {where(:enabled => true, :deleted => false)}  					

end
