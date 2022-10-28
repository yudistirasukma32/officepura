class Productorderitem < ActiveRecord::Base

	belongs_to :productorder
	belongs_to :product
	belongs_to :productrequestitem
	belongs_to :supplier
	belongs_to :paymentchecks

	attr_accessible :product_id, :productorder_id, :productrequestitem_id,
		:quantity, :price_per, :requestquantity, :total, :supplier_id, :paymentcheck_id
end