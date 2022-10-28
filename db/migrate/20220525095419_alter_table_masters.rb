class AlterTableMasters < ActiveRecord::Migration
  def up
    add_column :customers, :email_alt, :string, after: :email
    add_column :customers, :load_hour, :time
    add_column :customers, :unload_hour, :time
    add_column :vehicles, :office_id, :int
    add_column :routes, :pos, :string  
  end

  def down
    remove_column :customers, :email_alt
    remove_column :customers, :load_hour
    remove_column :customers, :unload_hour
    remove_column :vehicles, :office_id
    remove_column :routes, :pos
  end
end
