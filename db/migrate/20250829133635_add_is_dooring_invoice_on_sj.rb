class AddIsDooringInvoiceOnSj < ActiveRecord::Migration
  def up
    change_table :taxinvoiceitems do |t|
      t.boolean :is_dooring_invoice, :default => false
    end
  end

  def down
    change_table :taxinvoiceitems do |t|
      t.remove :is_dooring_invoice
    end

  end
end