class AlterTableEventAddTanktype < ActiveRecord::Migration
  def up
    add_column :events, :tanktype, :string
  end

  def down
    remove_column :events, :tanktype
  end
end
