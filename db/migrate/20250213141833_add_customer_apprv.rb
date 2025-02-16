class AddCustomerApprv < ActiveRecord::Migration
  def up
    add_column :customers, :dp, :boolean, :default => false
    add_column :customers, :dp_notes, :string
    add_column :customers, :ktp_photo, :boolean, :default => false
    add_column :customers, :npwp_photo, :boolean, :default => false
    add_column :customers, :pic_photo, :boolean, :default => false
    add_column :customers, :approved, :boolean, :default => false
  end

  def down
    remove_column :customers, :dp
    remove_column :customers, :dp_notes
    remove_column :customers, :ktp_photo
    remove_column :customers, :npwp_photo
    remove_column :customers, :pic_photo
    remove_column :customers, :approved
  end
end