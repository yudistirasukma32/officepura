class AddLocationOnOffices < ActiveRecord::Migration
  def up
    add_column :offices, :latitude, :string
    add_column :offices, :longitude, :string
    add_column :offices, :address, :string
    add_column :offices, :city, :string
    add_column :offices, :province, :string
    add_column :offices, :phone, :string
    add_column :offices, :mobile, :string
    add_column :offices, :garage, :boolean, :default => false
  end

  def down
    remove_column :offices, :latitude
    remove_column :offices, :longitude
    remove_column :offices, :address
    remove_column :offices, :city
    remove_column :offices, :province
    remove_column :offices, :phone
    remove_column :offices, :mobile
    remove_column :offices, :garage
  end
end
