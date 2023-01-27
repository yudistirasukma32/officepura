class Taxinvoiceitem < ActiveRecord::Base

	belongs_to :taxinvoice
	belongs_to :invoice
	belongs_to :office
	belongs_to :customer
	belongs_to :user

  	# Setup accessible (or protected) attributes for your model
  	attr_accessible :date, :description, :total, :deleted,
  				:sku_id, :weight_gross, :weight_net, :price_per,
  				:invoice_id, :taxinvoice_id, :office_id, :load_date, :unload_date, 
				:is_wholesale, :wholesale_price, :is_gross, :is_net, :user_id, :note,
				:reject_reason, :rejected

  	scope :active, lambda {where(:deleted => false)}

end
