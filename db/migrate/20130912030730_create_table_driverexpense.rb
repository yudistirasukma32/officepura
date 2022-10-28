class CreateTableDriverexpense < ActiveRecord::Migration
  def up
    create_table :driverexpenses, :force => true do |t|
      t.boolean :deleted, :default => false
      t.integer :driver_id
      t.integer :office_id
      t.date    :date
      t.text    :description
      t.string  :expensetype
      t.integer :deleteuser_id
      t.timestamps
    end

    add_column :driverexpenses, :total, :money, :default => 0

    create_table :receiptdrivers, :force => true do |t|
      t.boolean   :deleted, :default => false
      t.integer   :driverexpense_id
      t.string    :expensetype
      t.integer   :user_id
      t.integer   :deleteuser_id
      t.timestamps
    end

    add_column :receiptdrivers, :total, :money, :default => 0

  end

  def down
  end
end
