class AlterTableAddPaymentTrainAndPaymentShip < ActiveRecord::Migration
  def up
    change_table :invoices do |t|
      t.string :payment_train
      t.string :payment_ship
    end
  end

  def down
    change_table :invoices do |t|
      t.remove :payment_ship
      t.remove :payment_train
    end
  end
end
