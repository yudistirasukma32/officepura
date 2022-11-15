class AddBankNameToDriver < ActiveRecord::Migration
  def up
    # add_column :drivers, :bank_name, :string
    change_table :drivers do |t|
      t.string :bank_name
      t.references :bankexpensegroup, foreign_key: true, index: true
    end
  end
  def down
    remove_column :drivers, :bankexpensegroup_id
    remove_column :drivers, :bank_name
  end
end
