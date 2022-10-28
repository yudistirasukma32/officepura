class Receiptsale < ActiveRecord::Base

  belongs_to :sale
  belongs_to :user
  

  # Setup accessible (or protected) attributes for your model
  attr_accessible :sale_id, :date, :total, :user_id, :deleted, :deleteuser_id

  scope :active, lambda {where(:deleted => false)}

end