class AddTaxinvoiceOnOfficeexp < ActiveRecord::Migration
  def up
    add_column :officeexpenses, :taxinvoiced, :boolean, :default => false
    add_column :officeexpenses, :taxinvoice_id, :integer
    add_column :officeexpenses, :customer_id, :integer
    add_column :officeexpenses, :taxinvoice_item_name, :string
  end

  def down
    remove_column :officeexpenses, :taxinvoiced
    remove_column :officeexpenses, :taxinvoice_id
    remove_column :officeexpenses, :customer_id
    remove_column :officeexpenses, :taxinvoice_item_name
  end
end