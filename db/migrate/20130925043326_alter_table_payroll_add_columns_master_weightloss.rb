class AlterTablePayrollAddColumnsMasterWeightloss < ActiveRecord::Migration
  def up
  	add_column :payrolls, :master_weight_loss, :money, :default => 0
    add_column :payrolls, :master_accident, :money, :default => 0
    add_column :payrolls, :master_sparepart, :money, :default => 0
    add_column :payrolls, :master_bon, :money, :default => 0
    add_column :payrolls, :master_saving, :money, :default => 0
  end

  def down
  end
end
