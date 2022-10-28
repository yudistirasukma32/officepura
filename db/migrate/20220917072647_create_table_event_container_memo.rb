class CreateTableEventContainerMemo < ActiveRecord::Migration
  def up
    create_table :operators, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.string    :name
      t.string    :abbr
      t.text      :description 
      t.timestamps
    end

    create_table :containermemos, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.date 			:date
      t.string    :container_type
      t.integer   :container_id
      t.integer   :operator_id
      t.integer   :storage_day
      t.text      :description
      t.timestamps
    end

    add_column :containermemos, :container_fee, :money, :default => 0
    add_column :containermemos, :additional_fee, :money, :default => 0
    add_column :containermemos, :total, :money, :default => 0
  end

  def down
    drop_table    :operators rescue nil
    drop_table    :containermemos rescue nil
  end
end
