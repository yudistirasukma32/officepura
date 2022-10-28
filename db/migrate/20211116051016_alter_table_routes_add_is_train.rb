class AlterTableRoutesAddIsTrain < ActiveRecord::Migration
  def up
		add_column :routes, :is_train, :boolean, :default => false
  end

  def down
		remove_column :routes, :is_train
  end
end
