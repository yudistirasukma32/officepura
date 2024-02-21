class AlterTableTaxinvoicesAddedIsShowqtyLoadedAndIsShowqtyUnloaded < ActiveRecord::Migration
  def up
    change_table :taxinvoices do |t|
      t.boolean :is_showqty_loaded, :default => false
      t.boolean :is_showqty_unloaded, :default => false
    end
  end
  def down
    change_table :taxinvoices do |t|
      t.remove :is_showqty_unloaded
      t.remove :is_showqty_loaded
    end
  end
end
