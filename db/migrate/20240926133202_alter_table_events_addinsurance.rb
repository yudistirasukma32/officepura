class AlterTableEventsAddinsurance < ActiveRecord::Migration
  def up
    add_column :events, :is_insurance, :boolean, :default => false
    add_column :events, :tsi_total, :money, :default => 0
    add_column :events, :load_province, :string
    add_column :events, :unload_province, :string

    add_column :insurancevendors, :group, :string
    add_column :insuranceexpenses, :policy_number, :string
    add_column :insuranceexpenses, :insurance_name, :string
    add_column :insuranceexpenses, :top_days, :integer, :default => 0
    add_column :insuranceexpenses, :due_date, :date
  end

  def down
    remove_column :events, :is_insurance
    remove_column :events, :tsi_total
    remove_column :events, :load_province
    remove_column :events, :unload_province

    remove_column :insurancevendors, :group
    remove_column :insuranceexpenses, :policy_number
    remove_column :insuranceexpenses, :insurance_name
    remove_column :insuranceexpenses, :top_days
    remove_column :insuranceexpenses, :due_date
  end
end
