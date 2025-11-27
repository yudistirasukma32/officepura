class AlterTableCustnotesAddRevDate < ActiveRecord::Migration
  def up
    add_column :customernotes, :revision_date, :date 
    add_column :customernotes, :approved, :boolean, :default => false
  end

  def down
    remove_column :customernotes, :revision_date 
    remove_column :customernotes, :approved 
  end
end
