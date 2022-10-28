class AlterTableTaxinvAddSoSto < ActiveRecord::Migration
  def up
    add_column :taxinvoices, :so_no, :string
    add_column :taxinvoices, :sto_no, :string
    add_column :taxinvoices, :do_no, :string
  end

  def down
    remove_column :taxinvoices, :so_no 
    remove_column :taxinvoices, :sto_no
    remove_column :taxinvoices, :do_no
  end
end
