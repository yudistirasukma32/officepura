class AddBankNameToDriver < ActiveRecord::Migration
  def up
    # change_table :drivers do |t|
    #   t.string :bank_name
    #   t.references :bankexpensegroup, foreign_key: true, index: true
    # end
    add_column :drivers, :bank_name, :string
    add_column :drivers, :bankexpensegroup_id, :integer
  end
  def down
    remove_column :drivers, :bankexpensegroup_id
    remove_column :drivers, :bank_name
  end
end
