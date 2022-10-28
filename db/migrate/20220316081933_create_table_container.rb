class CreateTableContainer < ActiveRecord::Migration
  def up
  	create_table :containers, :force => true do |t|
  		t.boolean		:deleted, :default => false
  		t.boolean  	:enabled, :default => true
  		t.string		:containernumber
  		t.timestamps
  	end
  end

  def down
      drop_table 	:containers rescue nil
  end
end
