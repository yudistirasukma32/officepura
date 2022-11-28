class AddGstTaxOnRoutetrain < ActiveRecord::Migration
  def up
    add_column :routetrains, :gst_tax, :money
    add_column :routetrains, :total, :money
  end

  def down
    remove_column :routetrains, :gst_tax
    remove_column :routetrains, :total
  end
end
