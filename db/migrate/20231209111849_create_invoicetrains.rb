class CreateInvoicetrains < ActiveRecord::Migration
  def up
    create_table :invoicetrains, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.date      :date
      t.string    :code
      t.string    :train_status
      t.integer   :operator_id
      t.integer   :station_id
      t.integer   :route_id
      t.string    :container_type
      t.integer   :isotank_id
      t.string    :isotank_number
      t.integer   :container_id
      t.string    :container_number
      t.string    :description
      t.integer   :user_id
      t.integer   :deleteuser_id
      t.timestamps
    end
    add_column :invoicetrains, :total, :money, :default => 0
  end

  def down
    remove_column :invoicetrains, :total
    drop_table :invoicetrains rescue nil
  end
end
