class AddColumnCustomernameToQuotationgroups < ActiveRecord::Migration
  def up
    add_column :quotationgroups, :customer_name, :string
    add_column :quotationgroups, :customer_pic, :string
    add_column :quotationgroups, :customer_number, :string
    add_column :quotationgroups, :customer_email, :string
  end
  def down
    remove_column :quotationgroups, :customer_name
    remove_column :quotationgroups, :customer_pic
    remove_column :quotationgroups, :customer_number
    remove_column :quotationgroups, :customer_email
  end
end
