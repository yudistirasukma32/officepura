class AlterTableTaxinvoiceitemsAddEventName < ActiveRecord::Migration
  def up
    change_table :taxinvoiceitems do |t|
      t.string :event_name
    end
  end

  def down
    change_table :taxinvoiceitems do |t|
      t.remove :event_name
    end
  end
end
