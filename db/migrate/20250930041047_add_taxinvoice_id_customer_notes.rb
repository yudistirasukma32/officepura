class AddTaxinvoiceIdCustomerNotes < ActiveRecord::Migration
  def up
    add_column :customernotes, :taxinvoice_id, :int 
  end

  def down
    remove_column :customernotes, :taxinvoice_id 
  end
end
