class ChangeVolumeEventToInteger < ActiveRecord::Migration
  def up
    change_column :events, :volume, 'int USING volume::integer'
  end

  def down
    # change_column :events, :volume, :string
    change_column :events, :volume, 'float USING CAST(volume AS float)'
  end
end
