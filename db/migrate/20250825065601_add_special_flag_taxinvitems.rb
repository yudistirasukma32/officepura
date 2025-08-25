class AddSpecialFlagTaxinvitems < ActiveRecord::Migration
  def up
    add_column :taxinvoiceitems, :manual_vehicle_number, :string
  end

  def down
    remove_column :taxinvoiceitems, :manual_vehicle_number
  end
end
