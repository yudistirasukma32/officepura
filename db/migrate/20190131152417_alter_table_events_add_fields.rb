class AlterTableEventsAddFields < ActiveRecord::Migration
  def up
  	add_column :events, :customer_id, :integer, :index => true
  	add_column :events, :authorised, :boolean, :default => false
  	add_column :events, :authorised_dated, :datetime
    add_column :events, :payments_by, :string

  	add_index :events, :start_date
  	add_index :events, :end_date
  	add_index :events, :customer_id
  end

  def down
  end
end
