class CreateTaxinvoiceattachment < ActiveRecord::Migration
  def up
    create_table :taxinvoiceattachments, :force => true do |t|
      t.boolean :deleted, :default => false
      t.boolean :enabled, :default => true
      t.references :taxinvoice, foreign_key: true, index: true
      t.references :customer, foreign_key: true, index: true
      t.date :date
      t.string :attachment_type
      t.string :upload
      t.text :description
      t.integer :user_id
      t.integer :deleteuser_id
      t.timestamps
    end
  end

  def down
    drop_table :taxinvoiceattachments
  end
end
