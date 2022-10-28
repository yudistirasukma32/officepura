class Product < ActiveRecord::Base

	belongs_to :warehouse
	belongs_to :productgroup

	has_many :productrequestitems
	has_many :productorderitems
  has_many :productstocks

  # Setup accessible (or protected) attributes for your model
  attr_accessible :enabled, :name, 
  				  :sku, :barcode, :unit_name, :unit_price, :discount_price, :discount_percent,
  				  :description, :warehouse_id, :deleted, :uom, :distance, :status, :productgroup_id,
  				  :stock

  scope :active, lambda {where(:enabled => true, :deleted => false)}  					

end
