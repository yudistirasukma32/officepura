class CreateExpences < ActiveRecord::Migration
  def up

	create_table :officeexpenses, :force => true do |t|
		t.boolean 	:deleted, :default => false
		t.boolean  	:enabled, :default => true
		t.date	 		:date
		t.string		:expensetype
		t.text			:description
		t.integer 	:vehicle_id
		t.integer		:officeexpensegroup_id
		t.timestamps
	end
	add_column :officeexpenses, :total, :money, :default => 0

	create_table :bankexpenses, :force => true do |t|
		t.boolean 	:deleted, :default => false
		t.boolean  	:enabled, :default => true
		t.date 			:date
		t.integer		:debitgroup_id
		t.integer		:creditgroup_id
		t.integer		:taxinvoice_id
		t.text			:description
		t.timestamps
	end
	add_column :bankexpenses, :total, :money, :default => 0

	create_table :officeexpensegroups, :force => true do |t|
		t.boolean 	:deleted, :default => false
		t.boolean  	:enabled, :default => true
		t.integer	:officeexpensegroup_id
		t.string		:name
		t.text			:description
		t.timestamps
	end

	default = Officeexpensegroup.new
	default.name = "Umum"
	default.save

	create_table :bankexpensegroups, :force => true do |t|
		t.boolean 	:deleted, :default => false
		t.boolean  	:enabled, :default => true
		t.string		:name
		t.text			:description
		t.timestamps
	end
	add_column :bankexpensegroups, :total, :money, :default => 0

  end

  def down
  	drop_table 	:officeexpenses, 
				:bankexpenses, 
				:officeexpensegroups, 
				:bankexpensegroups

  end
end
