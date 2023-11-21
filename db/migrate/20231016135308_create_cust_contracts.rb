class CreateCustContracts < ActiveRecord::Migration
  def up 
    create_table :contracts, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.string    :name
      t.string    :code
      t.date      :date_start
      t.date      :date_end
      t.integer   :customer_id
      t.string    :contract_type
      t.string    :description
      t.timestamps
    end
  end
  
  # Drop table
  def down
    drop_table :contracts rescue nil
  end
end
