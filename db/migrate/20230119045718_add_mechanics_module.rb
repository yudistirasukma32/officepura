class AddMechanicsModule < ActiveRecord::Migration
  def up
    create_table :mechanics, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.string 		:name
      t.string    :phone
      t.string    :city
      t.text      :address
      t.text      :description 
      t.timestamps
    end

    create_table :mechaniclogs, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.date 			:date
      t.integer   :invoice_id
      t.integer   :vehicle_id
      t.integer   :driver_id
      t.integer   :mechanic_id
      t.string    :group
      t.text      :description 
      t.text      :comment
      t.string    :grade
      t.datetime  :datetime_start
      t.datetime  :datetime_end
      t.integer   :user_id
      t.integer   :deleteuser_id
      t.timestamps
    end
  end

  def down

    drop_table :mechanics rescue nil

    drop_table :mechaniclogs rescue nil

  end
end
