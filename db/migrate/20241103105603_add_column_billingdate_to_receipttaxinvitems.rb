class AddColumnBillingdateToReceipttaxinvitems < ActiveRecord::Migration
  def up
    add_column :receipttaxinvitems, :billingdate, :date
  end

  def down
    remove_column :receipttaxinvitems, :billingdate
  end
end
