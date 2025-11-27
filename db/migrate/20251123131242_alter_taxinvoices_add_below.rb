class AlterTaxinvoicesAddBelow < ActiveRecord::Migration
  def up
    create_table :receipttaxinvoices, :force => true do |t|
      t.boolean :deleted, :default => false
      t.boolean :enabled, :default => true
      t.integer :user_id
      t.integer :deleteuser_id
      t.integer :printuser_id
      t.date    :printdate
      t.date    :billing_date
      t.timestamps
    end

    add_column :taxinvoices, :receipttaxinvoice_id, :integer
    add_column :taxinvoices, :below_minimum, :boolean, :default => false

  end

  def down
    drop_table :receipttaxinvoices rescue nil
    remove_column :taxinvoices, :receipttaxinvoice_id
    remove_column :taxinvoices, :below_minimum 
  end

end