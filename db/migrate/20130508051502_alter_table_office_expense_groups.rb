class AlterTableOfficeExpenseGroups < ActiveRecord::Migration
  def up

  	default = Officeexpensegroup.new
	default.name = "Kantor"
	default.save		
	
	umum = Officeexpensegroup.find_by_name("Umum")
	default = Officeexpensegroup.new
	default.name = "Storing"
	default.officeexpensegroup_id = umum.id
	default.save		
	default = Officeexpensegroup.new
	default.name = "Koret"
	default.officeexpensegroup_id = umum.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Premi"
	default.officeexpensegroup_id = umum.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Gaji Supir"
	default.officeexpensegroup_id = umum.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Gaji Warnen"
	default.officeexpensegroup_id = umum.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Komisi"
	default.officeexpensegroup_id = umum.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Konsumsi Supir"
	default.officeexpensegroup_id = umum.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Klaim Susut"
	default.officeexpensegroup_id = umum.id
	default.save

	kantor = Officeexpensegroup.find_by_name("Kantor")
	default = Officeexpensegroup.new
	default.name = "Gaji Staff"
	default.officeexpensegroup_id = kantor.id
	default.save
	default = Officeexpensegroup.new
	default.name = "THR"
	default.officeexpensegroup_id = kantor.id
	default.save
	default = Officeexpensegroup.new
	default.name = "UH"
	default.officeexpensegroup_id = kantor.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Lembur"
	default.officeexpensegroup_id = kantor.id
	default.save
	default = Officeexpensegroup.new
	default.name = "ATK"
	default.officeexpensegroup_id = kantor.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Biaya Cetak Form"
	default.officeexpensegroup_id = kantor.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Inventaris Kantor"
	default.officeexpensegroup_id = kantor.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Jasa Konsultan"
	default.officeexpensegroup_id = kantor.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Jasa Security"
	default.officeexpensegroup_id = kantor.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Listrik"
	default.officeexpensegroup_id = kantor.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Telpon"
	default.officeexpensegroup_id = kantor.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Internet"
	default.officeexpensegroup_id = kantor.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Pulsa HP"
	default.officeexpensegroup_id = kantor.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Sewa Mesin Fotocopy"
	default.officeexpensegroup_id = kantor.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Jamsostek"
	default.officeexpensegroup_id = kantor.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Air Minum"
	default.officeexpensegroup_id = kantor.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Uang Bensin"
	default.officeexpensegroup_id = kantor.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Servis Motor / Mobil"
	default.officeexpensegroup_id = kantor.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Abunemen Keamanan"
	default.officeexpensegroup_id = kantor.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Biaya Kirim Barang"
	default.officeexpensegroup_id = kantor.id
	default.save
	default = Officeexpensegroup.new
	default.name = "Kantor Jakarta"
	default.officeexpensegroup_id = kantor.id
	default.save
  end

  def down
  end
end
