class AlterTableTaxinvoicesAddWb < ActiveRecord::Migration
  def up
    add_column :taxinvoices, :waybill, :string
    add_column :taxinvoices, :confirmeddate, :date, after: :sentdate
  end

  def down
    remove_column :taxinvoices, :waybill 
    remove_column :taxinvoices, :confirmeddate
  end
end
