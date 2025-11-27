class AddPoNoEvents < ActiveRecord::Migration
  def up
    add_column :events, :po_number, :string
  end

  def down
    remove_column :events, :po_number
  end
end
