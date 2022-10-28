def dumpdatabase
	puts 'Start backup data'

	system("rake db:data:dump RAILS_ENV=production")

	puts 'Starting copy data yml'

	path_file = File.join(Rails.root, "db", "data.yml")

	newfilename = "data_" + DateTime.now.strftime('%d%m%Y_%H%M') + ".yml"
	new_path_file = File.join(Rails.root,"db", newfilename)

	FileUtils.cp(path_file, new_path_file)
	puts 'Finish copy file'
end

def removeunuseddatayml
	puts 'Start delete data'
	path = File.join(Rails.root,"db",'*.yml')

	pastdate = Date.today - 3

	Dir.glob(path) do |yml|
	  # do work on files ending in .rb in the desired directory
	  filebasename = File.basename(yml,'.yml')
	  if !filebasename[pastdate.strftime('%d%m%Y')].nil?
	  	File.delete(yml)
	  end
	end
	puts 'Finish delete data'
end

scheduler = Rufus::Scheduler.new

scheduler.cron '0 5 * * *' do 
	removeunuseddatayml
	dumpdatabase
end

scheduler.cron '0 11 * * *' do 
	removeunuseddatayml
	dumpdatabase
end

#scheduler.start