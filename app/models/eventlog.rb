class Eventlog < ActiveRecord::Base

    belongs_to :user
    belongs_to :event

    # Setup accessible (or protected) attributes for your model
    attr_accessible :created_at, :updated_at, :deleted, :enabled, 
    :name, :note, :event_id, :user_id, :confirmed_at, :confirmed_by

    scope :active, lambda {where(:deleted => false)}

end
