class Quotation < ActiveRecord::Base

	belongs_to :commodity
	belongs_to :office
	belongs_to :quotationgroup
	belongs_to :routegroup

	has_many :quotationlogs

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :name, :commodity_id, :office_id, :routegroup_id, :transporttype, :distance, :price_per_type, :longitude_start, :latitude_start, :address_start, :longitude_end, :latitude_end, :address_end, :price_per, :quotationgroup_id, :description

	scope :active, lambda {where(:enabled => true, :deleted => false)}  					

	include PublicActivity::Model
	tracked owner: Proc.new { |controller, model| controller.current_user }

end
