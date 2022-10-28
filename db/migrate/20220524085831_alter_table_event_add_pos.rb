class AlterTableEventAddPos < ActiveRecord::Migration
  def up
    add_column :events, :cargo_number, :string
    add_column :events, :cargo_type, :string
    add_column :events, :volume, :string
    add_column :events, :office_id, :int
    add_column :events, :pos_sby, :boolean, :default => false
    add_column :events, :pos_smg, :boolean, :default => false
    add_column :events, :pos_jkt, :boolean, :default => false
    add_column :events, :pos_smt, :boolean, :default => false
    add_column :events, :pos_lorry, :boolean, :default => false
    add_column :events, :vendor_sby, :boolean, :default => false
    add_column :events, :vendor_smg, :boolean, :default => false
    add_column :events, :vendor_jkt, :boolean, :default => false
    add_column :events, :vendor_smt, :boolean, :default => false
    add_column :events, :vendor_lorry, :boolean, :default => false    
    add_column :events, :vendor_name, :string
  end

  def down
    remove_column :events, :cargo_number
    remove_column :events, :cargo_type
    remove_column :events, :volume
    remove_column :events, :office_id
    remove_column :events, :pos_sby
    remove_column :events, :pos_smg
    remove_column :events, :pos_jkt
    remove_column :events, :pos_smt
    remove_column :events, :pos_lorry
    remove_column :events, :vendor_sby
    remove_column :events, :vendor_smg
    remove_column :events, :vendor_jkt
    remove_column :events, :vendor_smt
    remove_column :events, :vendor_lorry
    remove_column :events, :vendor_name
  end
end
