class Assetgroup < ActiveRecord::Base

  has_many :assets
  # Setup accessible (or protected) attributes for your model
  attr_accessible :deleted, :name, :description, :percent_decrease

  scope :active, lambda {where(:deleted => false)}

end