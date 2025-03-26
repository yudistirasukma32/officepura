class AddTotalOnContract < ActiveRecord::Migration
  def up
    add_column :contracts, :total, :money
    add_column :routes, :contract_id, :integer
  end

  def down
    remove_column :contracts, :total
    remove_column :routes, :contract_id
  end
end
