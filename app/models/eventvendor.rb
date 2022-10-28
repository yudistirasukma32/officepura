class Eventvendor < ActiveRecord::Base

    belongs_to :event

    # Setup accessible (or protected) attributes for your model
    attr_accessible :deleted, :enabled, :event_id, :name, :vehicle_current_id, :iso_cont_number, :quantity

    scope :active, lambda {where(:deleted => false)}

end