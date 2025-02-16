class UpdateMechaniclogs < ActiveRecord::Migration
  def up
    add_column :mechaniclogs, :office_id, :int
    add_column :mechaniclogs, :request_type, :string
    add_column :mechaniclogs, :request_level, :string
    add_column :mechaniclogs, :request_location, :string
    add_column :mechaniclogs, :finished, :boolean, :default => false
  end

  def down
    remove_column :mechaniclogs, :office_id
    remove_column :mechaniclogs, :request_type
    remove_column :mechaniclogs, :request_level
    remove_column :mechaniclogs, :request_location
    remove_column :mechaniclogs, :finished
  end
end