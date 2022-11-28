class Operator < ActiveRecord::Base

	has_many :routetrains
	has_many :trainexpenses
	has_many :operators, class_name: 'Invoice', foreign_key: 'operator_id'
	has_many :shipoperators, class_name: 'Invoice', foreign_key: 'shipoperator_id'

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :name, :abbr, :description, :operatortype

	scope :active, lambda {where(:enabled => true, :deleted => false)}
	
	scope :multimode, lambda {where(:operatortype => 'MULTIMODE')}

	scope :train, lambda {where(:operatortype => 'TRAIN')}
	
	validates :name, uniqueness: true, presence: true

end
