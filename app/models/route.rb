class Route < ActiveRecord::Base

	belongs_to :customer
	belongs_to :routegroup
	belongs_to :office
	belongs_to :commodity

	has_many :allowances
	has_many :invoices
	has_many :events
	has_many :eventmemos
	has_many :routes
	has_many :routelocation	

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :name, :distance, :bonus,
								:tol_fee, :ferry_fee, :item_type, :price_per, :price_per_type, 
								:description, :customer_id, :routegroup_id, :deleted, :transporttype, :pos, 
								:route_id, :estimated_hour, :office_id, :commodity_id

	scope :active, lambda {where(:enabled => true, :deleted => false)}  					

	include PublicActivity::Model
	tracked owner: Proc.new { |controller, model| controller.current_user }

end
