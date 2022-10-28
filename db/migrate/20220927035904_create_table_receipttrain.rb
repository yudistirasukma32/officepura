class CreateTableReceipttrain < ActiveRecord::Migration
  def up

    create_table :receipttrains, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.integer   :trainexpense_id
      t.string    :description
      t.integer   :office_id
      t.integer   :officeexpensegroup_id
      t.integer   :bankexpensegroup_id
      t.string    :expensetype, :default => 'Kredit'
      t.integer   :user_id
      t.integer   :deleteuser_id
      t.timestamps
    end

    add_column :receipttrains, :total, :money, :default => 0

    add_column :trainexpenses, :expensetype, :string, :default => 'Kredit'
    add_column :trainexpenses, :officeexpensegroup_id, :int
    add_column :trainexpenses, :bankexpensegroup_id, :int
    add_column :trainexpenses, :deleteuser_id, :int

  end

  def down
    drop_table    :receipttrains rescue nil
    remove_column :trainexpenses, :expensetype
    remove_column :trainexpenses, :officeexpensegroup_id
    remove_column :trainexpenses, :bankexpensegroup_id
    remove_column :trainexpenses, :deleteuser_id
  end
end
