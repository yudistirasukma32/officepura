class AlterTableEventAddQtyTipe < ActiveRecord::Migration
  def up
      add_column :events, :qty, :int
      add_column :events, :invoicetrain, :boolean, :default => false
  end

  def down
      remove_column :events, :qty
      remove_column :events, :invoicetrain
  end
end
