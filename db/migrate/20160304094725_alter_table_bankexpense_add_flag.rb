class AlterTableBankexpenseAddFlag < ActiveRecord::Migration
  def up
  	add_column :bankexpenses, :bankledger, :boolean, :default => false
  	add_column :bankexpenses, :pettycashledger, :boolean, :default => false
  	add_column :bankexpenses, :money_in, :boolean
  end

  def down
  end
end
