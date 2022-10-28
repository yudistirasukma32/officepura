class Productrequestitem < ActiveRecord::Base

	belongs_to :productrequest
	belongs_to :product

	has_many :productorderitems

	attr_accessible :productrequest_id, :product_id, :quantity,
  					:stockgiven, :requestorder, :total
end