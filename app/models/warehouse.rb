class Warehouse < ActiveRecord::Base

	has_many :products

  # Setup accessible (or protected) attributes for your model
  attr_accessible :enabled, :name, :address, :city, :phone, :description, :deleted

  scope :active, lambda {where(:enabled => true, :deleted => false)}  					

end
