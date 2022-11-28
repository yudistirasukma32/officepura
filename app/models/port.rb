class Port < ActiveRecord::Base

  has_many :invoices
  has_many :origin_ports, class_name: 'Routeship', foreign_key: 'origin_port_id'
	has_many :destination_ports, class_name: 'Routeship', foreign_key: 'destination_port_id'
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :city, :address

  scope :active, lambda {where(:deleted => false)}

end
