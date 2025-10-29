class Taxgenericitem < ActiveRecord::Base

	belongs_to :taxinvoice
	belongs_to :office
	belongs_to :customer
	belongs_to :vehicle

  	# Setup accessible (or protected) attributes for your model
  	attr_accessible :date, :load_date, :unload_date, :description, :deleted, :sku_id, 
  				:quantity, :price_per, :total, :taxinvoice_id, :office_id, :weight_gross, :weight_net, :customer_id, 
				:vehicle_id, :vehicle_number, :container_number

  	scope :active, lambda {where(:deleted => false)}

end
