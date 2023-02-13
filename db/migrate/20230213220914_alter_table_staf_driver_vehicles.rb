class AlterTableStafDriverVehicles < ActiveRecord::Migration
  def up
    add_column :drivers, :origin, :string
    add_column :staffs, :origin, :string
    add_column :staffs, :emergency_contact, :string
    add_column :staffs, :family_status, :string
    add_column :staffs, :family_card_number, :string
    add_column :vehicles, :bpkb_number, :string
    add_column :vehicles, :owner_name, :string
    add_column :vehicles, :owner_address, :text
    add_column :vehicles, :brand, :string
    add_column :vehicles, :color, :string
    add_column :vehicles, :tire_amount, :string
  end

  def down
    remove_column :drivers, :origin
    remove_column :staffs, :origin
    remove_column :staffs, :emergency_contact
    remove_column :staffs, :family_status
    remove_column :staffs, :family_card_number
    remove_column :vehicles, :bpkb_number
    remove_column :vehicles, :owner_name
    remove_column :vehicles, :owner_address
    remove_column :vehicles, :brand
    remove_column :vehicles, :color
    remove_column :vehicles, :tire_amount
  end
end
