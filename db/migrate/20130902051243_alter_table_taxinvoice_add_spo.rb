class AlterTableTaxinvoiceAddSpo < ActiveRecord::Migration
  def up
  	add_column :taxinvoices, :spo_no, :string
    add_column :taxinvoices, :sentdate, :date, before: :duedate
  end

  def down
  end
end
