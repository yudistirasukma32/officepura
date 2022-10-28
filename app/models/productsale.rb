class Productsale < ActiveRecord::Base

  has_many :saleitems


  # Setup accessible (or protected) attributes for your model
  attr_accessible :deleted, :name, :unit_name, :unit_price, :onsale

  scope :active, lambda {where(:deleted => false)}

end