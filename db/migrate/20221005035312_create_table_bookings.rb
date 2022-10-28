class CreateTableBookings < ActiveRecord::Migration
  def up

    create_table :bookings, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.date      :date
      t.integer   :office_id
      t.integer   :event_id
      t.integer   :vehicle_id
      t.string    :description
      t.integer   :user_id
      t.integer   :deleteuser_id
      t.timestamps
    end

  end

  def down
    drop_table    :bookings rescue nil
  end
end
