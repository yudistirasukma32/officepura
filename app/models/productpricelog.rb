class Productpricelog < ActiveRecord::Base

	belongs_to :product

  # Setup accessible (or protected) attributes for your model
  attr_accessible :old_price, :new_price, :product_id


end
