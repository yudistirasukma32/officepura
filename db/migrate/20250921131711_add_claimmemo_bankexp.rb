class AddClaimmemoBankexp < ActiveRecord::Migration
  def up
    add_column :bankexpenses, :claimmemo_id, :int
  end

  def down
    remove_column :bankexpenses, :claimmemo_id
  end
end
