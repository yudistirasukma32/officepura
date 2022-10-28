class Asset < ActiveRecord::Base
	belongs_to :assetgroup
	has_many :assetorders
  # Setup accessible (or protected) attributes for your model
  attr_accessible :enabled, :name, :date_purchase, :assetgroup_id,
  								:amount, :amount_type, :quantity, :asset_type, :description, :deleted

  scope :active, lambda {where(:enabled => true, :deleted => false)}  					

end
