class Routeship < ActiveRecord::Base

	belongs_to :operator
	belongs_to :origin_port, class_name: "Port"
	belongs_to :destination_port, class_name: "Port"

	has_many :shipexpenses
	has_many :invoices

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :name,
	:operator_id, :origin_port_id, :destination_port_id, :price_per, :tempo, :description

	validates :name, presence: true
	validates :operator_id, presence: true
	validates :destination_port_id, presence: true
	validates :origin_port_id, presence: true

	scope :active, lambda {where(:enabled => true, :deleted => false)}

end
