class Role < ActiveRecord::Base
  has_many :userroles

  # Setup accessible (or protected) attributes for your model
  attr_accessible :deleted, :enabled, :name, :description

  scope :active, lambda {where(:enabled => true, :deleted => false)}
end