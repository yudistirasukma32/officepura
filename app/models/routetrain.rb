class Routetrain < ActiveRecord::Base

	belongs_to :operator
	belongs_to :origin_station, class_name: "Station"
	belongs_to :destination_station, class_name: "Station"

	has_many :trainexpenses
	has_many :invoices

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :name, :container_type, :size,
	:operator_id, :origin_station_id, :destination_station_id, :price_per

	validates :name, presence: true
	validates :operator_id, presence: true
	validates :destination_station_id, presence: true
	validates :origin_station_id, presence: true

	scope :active, lambda {where(:enabled => true, :deleted => false)}

end
