class AlterTableAddDescPayrolls < ActiveRecord::Migration
  def up
    add_column :payrolls, :claim_description, :text
    add_column :payrolls, :saving_description, :text
  end

  def down
    remove_column :payrolls, :claim_description
    remove_column :payrolls, :saving_description
  end
end