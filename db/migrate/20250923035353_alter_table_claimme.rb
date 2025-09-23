class AlterTableClaimme < ActiveRecord::Migration
  def up
    add_column :claimmemos, :driver_charge, :money, :default => 0
    add_column :claimmemos, :claim_letter, :string
  end

  def down
    remove_column :claimmemos, :driver_charge
    remove_column :claimmemos, :claim_letter
  end
end
