class Customernote < ActiveRecord::Base
  self.table_name = "customernotes"

  belongs_to :customer
 
  scope :enabled, where(:enabled => true, :deleted => false)  # Rails 3.x style
  scope :deleted, where(:deleted => true)

  validates :description, :presence => true

  attr_accessible :deleted, :enabled, :customer_id, 
                  :description, :user_id, :deleteuser_id
end
