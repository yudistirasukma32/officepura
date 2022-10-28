class Sale < ActiveRecord::Base

  has_many :saleitems
  has_many :receiptsales


  # Setup accessible (or protected) attributes for your model
  attr_accessible :deleted, :date, :description, :user_id, :total, :deleteuser_id

  scope :active, lambda {where(:deleted => false)}

end