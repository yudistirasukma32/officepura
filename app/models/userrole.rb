class Userrole < ActiveRecord::Base
  belongs_to :user
  belongs_to :role

  # Setup accessible (or protected) attributes for your model
  attr_accessible :user_id, :role_id
end