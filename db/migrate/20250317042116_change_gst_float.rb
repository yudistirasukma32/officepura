class ChangeGstFloat < ActiveRecord::Migration
  def change
    change_column :customers, :gst_percentage, :float, default: 0
  end
end
