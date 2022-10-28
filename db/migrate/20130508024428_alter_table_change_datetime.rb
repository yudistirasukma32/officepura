class AlterTableChangeDatetime < ActiveRecord::Migration
  def up
  	change_column :staffs, :driver_licence_expiry, :date
  	change_column :staffs, :id_card_expiry, :date
  	change_column :staffs, :start_working, :date

  	change_column :drivers, :driver_licence_expiry, :date
  	change_column :drivers, :id_card_expiry, :date
  	change_column :drivers, :start_working, :date

  	change_column :helpers, :driver_licence_expiry, :date
  	change_column :helpers, :id_card_expiry, :date

  	change_column :vehicles, :id_expiry, :date
  	change_column :vehicles, :next_checkup_date, :date
  	change_column :vehicles, :next_registration_date, :date
  	change_column :vehicles, :next_tax_date, :date

  	change_column :assets, :date_purchase, :date

  	change_column :taxinvoiceitems, :date, :date
  end

  def down
  	change_column :staffs, :driver_licence_expiry, :datetime
  	change_column :staffs, :id_card_expiry, :datetime
  	change_column :staffs, :start_working, :datetime

  	change_column :drivers, :driver_licence_expiry, :datetime
  	change_column :drivers, :id_card_expiry, :datetime
  	change_column :drivers, :start_working, :datetime

  	change_column :helpers, :driver_licence_expiry, :datetime
  	change_column :helpers, :id_card_expiry, :datetime

  	change_column :vehicles, :id_expiry, :datetime
  	change_column :vehicles, :next_checkup_date, :datetime
  	change_column :vehicles, :next_registration_date, :datetime
  	change_column :vehicles, :next_tax_date, :datetime

  	change_column :assets, :date_purchase, :datetime

  	change_column :taxinvoiceitems, :date, :datetime
  end
end
