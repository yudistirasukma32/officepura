class Productorderitemreturn < ActiveRecord::Base

	belongs_to :productorder
	belongs_to :product
	belongs_to :supplier

	attr_accessible :product_id, :productorder_id,
		:quantity, :price_per, :total, :supplier_id, :date, :description, :bon
end