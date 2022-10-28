class CreateIncentives < ActiveRecord::Migration
  def up

		create_table :vehicleincentivegroups, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
			t.string   	:name
			t.text    	:description
			t.timestamps
		end		

		add_column :vehicleincentivegroups, :incentive, :money, :default => 0 rescue nil

  	add_column :vehicles, :vehicleincentivegroup_id, :int rescue nil

  end

  def down
  	drop_table 	:vehicleincentivegroups rescue nil
  end
end
