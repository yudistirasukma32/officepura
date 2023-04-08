class CreateTableBanks < ActiveRecord::Migration
  def up 
    create_table :banks, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.string    :name
      t.string   :bank_account_name
      t.string   :bank_account_number
      t.string   :note
      t.timestamps
    end

    add_column :taxinvoices, :bank_id, :integer
    add_column :taxinvoices, :booking_code, :string
  end
  
  # Drop table
  def down
    drop_table :banks rescue nil
    remove_column :taxinvoices, :bank_id
    remove_column :taxinvoices, :booking_code
  end
end
