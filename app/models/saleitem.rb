class Saleitem < ActiveRecord::Base

  belongs_to :sale
  belongs_to :productsale


  # Setup accessible (or protected) attributes for your model
  attr_accessible :sale_id, :productsale_id, :quantity, :price_per, :total

end