class Transporttype < ActiveRecord::Base

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name

  scope :active, lambda {where(:deleted => false)}

end
