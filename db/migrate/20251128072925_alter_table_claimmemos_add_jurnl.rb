class AlterTableClaimmemosAddJurnl < ActiveRecord::Migration
  def up
    add_column :claimmemos, :journal_note, :string
    add_column :claimmemos, :taxinvoice_note, :string
  end

  def down
    remove_column :claimmemos, :journal_note
    remove_column :claimmemos, :taxinvoice_note
  end
end