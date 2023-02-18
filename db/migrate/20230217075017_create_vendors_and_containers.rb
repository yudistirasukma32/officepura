class CreateVendorsAndContainers < ActiveRecord::Migration
  def up
    create_table :vendors, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.string    :name
      t.string    :npwp
      t.string    :phone
      t.string    :mobile
      t.string    :pic_name
      t.string    :email 
      t.text      :description 
      t.string    :group, :default => 'Container'
      t.integer   :user_id
      t.integer   :deleteuser_id
      t.timestamps
    end

    add_column :containers, :vendor_id, :integer

    create_table :vendorvehicles, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.integer   :vendor_id
      t.string    :current_id
      t.string    :year_made
      t.string    :brand
      t.string    :color
      t.string    :tire_amount
      t.text      :description
      t.integer   :user_id
      t.integer   :deleteuser_id
      t.timestamps
    end

    create_table :containerexpenses, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.date 			:date
      t.integer   :event_id
      t.integer   :invoice_id
      t.integer   :container_id
      t.text      :description 
      t.integer   :user_id
      t.string    :expensetype, :default => 'Kredit'
      t.integer   :officeexpensegroup_id
      t.integer   :bankexpensegroup_id
      t.integer   :deleteuser_id
      t.timestamps
    end

    create_table :receiptcontainers, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.date 			:date
      t.integer   :containerexpense_id
      t.text      :description 
      t.integer   :user_id
      t.string    :expensetype, :default => 'Kredit'
      t.integer   :officeexpensegroup_id
      t.integer   :bankexpensegroup_id
      t.timestamps
    end

    add_column :containerexpenses, :total, :money, :default => 0
    add_column :receiptcontainers, :total, :money, :default => 0

  end

  def down
    drop_table :vendors rescue nil
    remove_column :containers, :vendor_id

    drop_table :vendorvehicles rescue nil

    drop_table :containerexpenses rescue nil
    drop_table :receiptcontainers rescue nil
    remove_column :containerexpenses, :total
    remove_column :receiptcontainers, :total
  end
end
