class AddTrailerTol < ActiveRecord::Migration
  def up
    add_column :routes, :tol_fee_trailer, :money, :default => 0
  end

  def down
    remove_column :routes, :tol_fee_trailer
  end
end