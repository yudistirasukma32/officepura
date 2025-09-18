class CreateCustomerNotes < ActiveRecord::Migration
  def change
    create_table :customernotes do |t|
      t.boolean :deleted, :default => false
      t.boolean :enabled, :default => true
      t.references :customer, foreign_key: true, index: true
      t.text :description
      t.integer :user_id
      t.integer :deleteuser_id
      t.timestamps
    end
  end
end