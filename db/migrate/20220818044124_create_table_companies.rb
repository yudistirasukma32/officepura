class CreateTableCompanies < ActiveRecord::Migration
  def up
  	create_table :companies, :force => true do |t|
      t.boolean   :deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.string    :name
      t.string    :abbr
      t.string    :description
      t.timestamps
  	end

    # Assign existing to default site
    default = Company.new
    default.name = "Rajawali Dwi Putra"
    default.abbr = "RDPI"
    default.save

    # Assign existing to default site
    default = Company.new
    default.name = "Putra Rajawali Trans"
    default.abbr = "PURA"
    default.save

    add_column :events, :company_id, :int
    add_column :taxinvoices, :company_id, :int
      
  end

  def down
      drop_table    :companies rescue nil
      remove_column :events, :company_id
      remove_column :taxinvoices, :company_id
  end
end
