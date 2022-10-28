class Setting < ActiveRecord::Base

	attr_accessible :name, :description, :value, :enabled, :editable, :group

end
