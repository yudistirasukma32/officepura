class CreateTableShipExpenses < ActiveRecord::Migration
  def up
    create_table :shipexpenses, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.date 			:date
      t.integer   :routeship_id
      t.integer   :invoice_id
      t.text      :description 
      t.integer   :user_id
      t.string    :expensetype, :default => 'Kredit'
      t.integer   :officeexpensegroup_id
      t.integer   :bankexpensegroup_id
      t.integer   :deleteuser_id
      t.timestamps
    end

    create_table :receiptships, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.date 			:date
      t.integer   :shipexpense_id
      t.text      :description 
      t.integer   :user_id
      t.string    :expensetype, :default => 'Kredit'
      t.integer   :officeexpensegroup_id
      t.integer   :bankexpensegroup_id
      t.timestamps
      end
      
      add_column :shipexpenses, :total, :money, :default => 0
      add_column :receiptships, :total, :money, :default => 0
      
    end

  def down
    drop_table :shipexpenses rescue nil
    drop_table :receiptships rescue nil
    remove_column :shipexpenses, :total
    remove_column :receiptships, :total
  end
end
