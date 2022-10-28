class CreateLegalities < ActiveRecord::Migration
  def change
    create_table :legalities do |t|
			t.boolean :deleted, :default => false
			t.boolean :enabled, :default => true
      t.string :name
      t.string :number
      t.text :description
			t.date :validity
      t.timestamps
    end
  end
end
