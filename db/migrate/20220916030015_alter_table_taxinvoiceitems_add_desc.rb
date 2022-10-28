class AlterTableTaxinvoiceitemsAddDesc < ActiveRecord::Migration
  def up
    add_column :taxinvoiceitems, :note, :string
  end

  def down
    remove_column :taxinvoiceitems, :note
  end
end
