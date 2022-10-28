class Ship < ActiveRecord::Base

  has_many :invoices

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :number, :imo, :builder, :year_of_build, :description

  scope :active, lambda {where(:deleted => false)}

end
