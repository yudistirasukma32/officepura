class CreateTableIsotank < ActiveRecord::Migration
  def up
  	create_table :isotanks, :force => true do |t|
  		t.boolean		:deleted, :default => false
  		t.boolean  	:enabled, :default => true
  		t.string		:isotanknumber
  		t.timestamps
  	end
  end

  def down
  end
end
