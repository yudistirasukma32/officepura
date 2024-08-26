class CreateReceipttaxinvitems < ActiveRecord::Migration
  def up
    create_table :receipttaxinvitems, :force => true do |t|
      t.boolean :deleted, :default => false
      t.boolean :enabled, :default => true
      t.integer :user_id
      t.integer :deleteuser_id
      t.integer :printuser_id
      t.date :printdate
      t.timestamps
    end

    add_column :taxinvoiceitems, :receipttaxinvitem_id, :integer
  end

  def down
    drop_table :receipttaxinvitems rescue nil
    remove_column :taxinvoiceitems, :receipttaxinvitem_id
  end
end
