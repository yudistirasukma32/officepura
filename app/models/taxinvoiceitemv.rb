class Taxinvoiceitemv < ActiveRecord::Base

	belongs_to :customer
	belongs_to :event
	belongs_to :office
	belongs_to :taxinvoice

  	# Setup accessible (or protected) attributes for your model
  	attr_accessible :oriitem, :date, :total, :deleted, :sku_id, :vehicle_number, :weight_gross, :weight_net, :event_id, :customer_id, :price_per, :taxinvoice_id, :office_id, :load_date, :unload_date, :is_wholesale, :wholesale_price, :is_gross, :is_net, :reject_reason, :rejected

  	scope :active, lambda {where(:deleted => false)}

end
