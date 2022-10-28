class Eventsalesorder < ActiveRecord::Base

    belongs_to :customer
    belongs_to :event

    # Setup accessible (or protected) attributes for your model
    attr_accessible :deleted, :enabled, :customer_id, :event_id, :long_id

    scope :active, lambda {where(:deleted => false)}

end