class AlterTaxinvAddWaiting < ActiveRecord::Migration
  def up
    add_column :taxinvoices, :waiting, :boolean, :default => false
  end

  def down
    remove_column :taxinvoices, :waiting
  end
end
