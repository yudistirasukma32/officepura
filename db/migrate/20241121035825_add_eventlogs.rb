class AddEventlogs < ActiveRecord::Migration
  def up 
    create_table :eventlogs, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.string    :name
      t.string    :note
      t.integer   :event_id
      t.integer   :user_id
      t.integer   :confirmed_by
      t.datetime  :confirmed_at
      t.timestamps
    end
  end
  
  # Drop table
  def down
    drop_table :eventlogs rescue nil
  end
end
