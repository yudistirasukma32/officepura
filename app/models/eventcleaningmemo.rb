class Eventcleaningmemo < ActiveRecord::Base

    belongs_to :event
	belongs_to :driver
	belongs_to :vehicle
	belongs_to :isotank
    belongs_to :container

    validates_presence_of :driver_id, message: "Driver wajib diisi"
    validates_presence_of :vehicle_id, message: "Kendaraan wajib diisi"
    validate :check_driver_and_truck_id
    # Setup accessible (or protected) attributes for your model
    attr_accessible :date, :event_id, :driver_id, :vehicle_id, :container_id, :isotank_id, :description, :next_description

    scope :active, lambda {where(:deleted => false)}
    private
    def check_driver_and_truck_id
        if self.driver_id.to_i == 0
            errors.add(:driver_id, message: "Driver wajib diisi")
        end
        if self.vehicle_id.to_i == 0
            errors.add(:vehicle_id, message: "Truck wajib diisi")
        end
    end
end