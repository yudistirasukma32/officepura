class AlterTableTaxinvoiceAddMemo < ActiveRecord::Migration
  def up
  	add_column :taxinvoices, :extra_cost, :money, :default => 0
  	add_column :taxinvoices, :extra_cost_info, :text
  	add_column :taxinvoices, :total_in_words, :text
  end

  def down
  end
end
