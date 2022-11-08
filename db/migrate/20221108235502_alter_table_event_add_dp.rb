class AlterTableEventAddDp < ActiveRecord::Migration
  def up
    add_column :events, :downpayment_amount, :money
    add_column :events, :downpayment_date, :date
  end

  def down
    remove_column :events, :downpayment_amount
    remove_column :events, :downpayment_date
  end
end
