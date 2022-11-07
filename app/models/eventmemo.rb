class Eventmemo < ActiveRecord::Base

    belongs_to :event
	belongs_to :driver
	belongs_to :vehicle
	belongs_to :customer
	belongs_to :route
    belongs_to :commodity
	belongs_to :isotank
    belongs_to :container
    
    has_many :invoices
    
    validates_presence_of :driver_id, message: "Driver wajib diisi"
    validates_presence_of :vehicle_id, message: "Kendaraan wajib diisi"
    validates_presence_of :route_id, message: "Jurusan wajib diisi"
    validates_presence_of :commodity_id, message: "Jurusan wajib diisi"
    validate :check_driver_and_truck_id

    # Setup accessible (or protected) attributes for your model
    attr_accessible :date, :event_id, :driver_id, :customer_id, :vehicle_id, :commodity_id, 
    :quantity, :route_id, :route_summary, :container_id, :isotank_id, :description, :enabled, :deleted, :driver_phone, :platform_type 
 
    scope :active, lambda {where(:deleted => false)}
    
    def check_driver_and_truck_id
        if self.driver_id.to_i == 0
            errors.add(:driver_id, message: "Driver wajib diisi")
        end
        if self.vehicle_id.to_i == 0
            errors.add(:vehicle_id, message: "Truck wajib diisi")
        end
        if self.route_id.to_i == 0
            errors.add(:route_id, message: "Jurusan wajib diisi")
        end
        if self.commodity_id.to_i == 0
            errors.add(:commodity_id, message: "Jurusan wajib diisi")
        end
    end
end