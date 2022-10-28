class Supplierpayment < ActiveRecord::Base

	belongs_to :supplier

  	# Setup accessible (or protected) attributes for your model
  	attr_accessible :date, :supplier_id, :no_giro, :total, :due_date

end