class AddColumnHelperfeeToPayroll < ActiveRecord::Migration
  def change
  	add_column :payrolls, :helper_fee, :money, :default => 0
  end
end
