class AlterTableReceipttaxinvoice < ActiveRecord::Migration
  def up
    add_column :receipttaxinvoices, :taxinvoice_list, :text
  end

  def down
    remove_column :receipttaxinvoices, :taxinvoice_list
  end
end