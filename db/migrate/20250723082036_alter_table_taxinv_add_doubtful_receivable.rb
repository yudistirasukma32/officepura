class AlterTableTaxinvAddDoubtfulReceivable < ActiveRecord::Migration
  def up
    add_column :taxinvoices, :doubtful_ar, :boolean, :default => false
    add_column :taxinvoices, :doubtful_ar_note, :string
  end

  def down
    remove_column :taxinvoices, :doubtful_ar
    remove_column :taxinvoices, :doubtful_ar_note
  end
end
