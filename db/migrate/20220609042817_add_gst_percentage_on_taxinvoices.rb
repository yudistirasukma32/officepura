class AddGstPercentageOnTaxinvoices < ActiveRecord::Migration
  def up
    add_column :taxinvoices, :gst_percentage, :float, default: 0
  end

  def down
    remove_column :taxinvoices, :gst_percentage
  end
end
