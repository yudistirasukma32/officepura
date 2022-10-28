class CreateTableTireBudgets < ActiveRecord::Migration
  def up
  	create_table :tirebudgets, :force => true do |t|
  		t.boolean		:deleted, :default => false
  		t.integer		:vehicle_id
  		t.integer		:productgroup_id
  		t.integer		:budget
  		t.timestamps
  	end


  end
end
