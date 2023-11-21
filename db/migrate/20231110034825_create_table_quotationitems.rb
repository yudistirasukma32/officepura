class CreateTableQuotationitems < ActiveRecord::Migration
  def up
    remove_column :quotations, :long_id
    remove_column :quotations, :date
    remove_column :quotations, :confirmed_date
    remove_column :quotations, :customer_id
    remove_column :quotations, :status
    remove_column :quotations, :created_by
    remove_column :quotations, :confirmed_by
    remove_column :quotations, :rejected_by
    add_column :quotations, :description, :text
    add_column :quotations, :quotationgroup_id, :integer

    create_table :quotationgroups, :force => true do |t|
      t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
      t.string    :long_id
      t.date      :date
      t.date      :confirmed_date
      t.integer  	:customer_id
      t.timestamps
      t.string    :status
      t.integer   :created_by
      t.integer   :confirmed_by
      t.integer   :rejected_by
      t.text      :description
      t.text      :notes
		end
    add_column :quotationgroups, :total, :money, :default => 0
  end

  def down
    remove_column :quotations, :quotationgroup_id
    remove_column :quotations, :description
    add_column :quotations, :long_id, :string
    add_column :quotations, :date, :date
    add_column :quotations, :confirmed_date, :date
    add_column :quotations, :customer_id, :integer
    add_column :quotations, :status, :string
    add_column :quotations, :created_by, :integer
    add_column :quotations, :confirmed_by, :integer
    add_column :quotations, :rejected_by, :integer

    drop_table :quotationgroups
  end
end
