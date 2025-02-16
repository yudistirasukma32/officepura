class UpdateQuotationgroup < ActiveRecord::Migration
  def up
    add_column :quotationgroups, :reviewed, :boolean, :default => false
    add_column :quotationgroups, :reviewed_at, :datetime
    add_column :quotationgroups, :reviewed_by, :int
    add_column :quotationgroups, :confirmed, :boolean, :default => false
    add_column :quotationgroups, :confirmed_at, :datetime
    add_column :quotationgroups, :is_sent, :boolean, :default => false
    add_column :quotationgroups, :sent_date, :datetime
    add_column :quotationgroups, :customer_approved, :boolean, :default => false
    add_column :quotationgroups, :customer_approved_date, :datetime
  end

  def down
    remove_column :quotationgroups, :reviewed
    remove_column :quotationgroups, :reviewed_at
    remove_column :quotationgroups, :reviewed_by
    remove_column :quotationgroups, :confirmed
    remove_column :quotationgroups, :confirmed_at
    remove_column :quotationgroups, :is_sent
    remove_column :quotationgroups, :sent_date
    remove_column :quotationgroups, :customer_approved
    remove_column :quotationgroups, :customer_approved_date
  end
end
