class AddRejectReasonDo < ActiveRecord::Migration
  def up
    add_column :events, :reject_reason, :string
  end

  def down
    remove_column :events, :reject_reason
  end
end
