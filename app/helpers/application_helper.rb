module ApplicationHelper
	def nl2br(string)
		string.gsub("\n\r","<br>").gsub("\r", "").gsub("\n", "<br />")
	end

	def slugify(string) 
		string.downcase.gsub(/\W/,"-")
	end

	def zeropad(num)
		return "%06d" % num
	end
  
	def show_flash(flash)
		html = []
		flash.map do |key, msg|
		  html << 
			content_tag(:div, :class => "#{key}", :id => "flash") do
			  msg
			end  
		end
		html.join("\n").html_safe
	end

	def getwords(input, len)
		output = ""
		if input.length > len.to_i
			output = input.slice(0, len.to_i) + " ..."
		end
		return output.length > 0 ? output : input	
	end

	def clean_currency number
		number.gsub('.','').gsub(',','.') if !number.nil?
	end
	
	# def authenticate
		# if session[:username].nil?
		# 	redirect_to "/login" and return false
		# end
		# return true
	# end

	def checkadmin
		if !current_user.adminrole
			redirect_to "/notauthorized" and return false
		end
		return true
	end

	def checkrole names

		# better put in session than keep querying user roles
		if session[:roles].nil? or session[:roles].empty?
			session[:roles] = Userrole.joins(:role).where(:user_id => current_user.id).pluck("roles.name")
		end

		flag = false
		roles = names.split(',')

		if current_user.adminrole || current_user.owner
			flag = true
		else
			roles.each do |role|
				flag = session[:roles].include?role.strip
				break if flag
			end
		end

		return flag
	end

	def role_exist name
		Userrole.joins(:role).where("user_id = ? AND roles.name = ?", current_user.id, name).any? rescue false || false
	end

	def cek_roles role_type
	    role = checkrole role_type
	    if !role
	      return false
	    else
	      return true
	    end
	end

	def checkroleonly role
		roles = role.split(',')
		crole = Role.where(:name => roles).pluck(:id)

		userrole = Userrole.where(:user_id => current_user.id, :role_id => crole)
		if userrole.any?
			return true
		else
			return false
		end
	end	

	def to_currency number, unit=""
		return number_to_currency(number, :unit => unit, :precision => 0, :separator => ",", :delimiter => ".")
	end

	def to_currency_bank number, unit=""
		return number_to_currency(number, :unit => unit, :precision => 2, :separator => ",", :delimiter => ".")
	end

	def update_route_province route_id, load_province, unload_province
		route = Route.find(route_id)
		if !route.nil?
			route.load_province = load_province if route.load_province.nil?
			route.unload_province = unload_province if route.unload_province.nil?
			route.save
		end
	end

	def updateinvoice_count event_id

		event = Event.find(event_id) rescue nil
		if !event.nil?
			invoice_count = Invoice.active.where('event_id = ?', event.id).where('id not in (select invoice_id from invoicereturns where deleted = false)').count
			event.invoice_count = invoice_count
			event.save
		end

	end

	def updateinvoiceconfirmed_count event_id

		event = Event.find(event_id) rescue nil
		if !event.nil?
			invoiceconfirmed_count = Invoice.active.where('event_id = ?', event.id).where('id not in (select invoice_id from invoicereturns where deleted = false)').where('id in (select invoice_id from receipts where deleted = false)').count
			event.invoiceconfirmed_count = invoiceconfirmed_count
			event.save
		end

	end

	def updateinvoice_taxitems_count event_id

		event = Event.find(event_id) rescue nil

		if !event.nil?
			invoices = Invoice.active.select('id').where('event_id = ?', event.id).where('id not in (select invoice_id from invoicereturns where deleted = false)').where('id in (select invoice_id from receipts where deleted = false)')
			invoice_taxitems_count = Taxinvoiceitem.active.select('invoice_id, total')
									 .where("taxinvoiceitems.invoice_id IN (?) AND taxinvoiceitems.total > '0'", invoices).count
			event.invoice_taxitems_count = invoice_taxitems_count
			event.save
		end

	end

	def invoice_taxinv_count event_id

	event = Event.find(event_id) rescue nil

	if !event.nil?
		invoices = Invoice.active.select('id').where('event_id = ?', event.id).where('id not in (select invoice_id from invoicereturns where deleted = false)').where('id in (select invoice_id from receipts where deleted = false)')
		invoice_taxinv_count = Taxinvoiceitem.active.select('invoice_id, total')
								 .where("taxinvoiceitems.invoice_id IN (?) AND taxinvoiceitems.total > '0' AND taxinvoiceitems.taxinvoice_id is not null", invoices).count
		event.invoice_taxinv_count = invoice_taxinv_count
		event.save
	end

	end

	def updateproductstock value, product_id
		product = Product.find(product_id)
		if !product.nil?
			product.stock = 0 if product.stock.nil?
			product.stock += value
			product.save
		end
	end

	def updateofficecash val, date = nil
		officecash = Setting.find_by_name("Saldo Kas Kantor") rescue nil
		date = Date.today.strftime('%d-%m-%Y') if date.nil?

		updatecashdailylog val, date.to_date, officecash.value.to_i

		if !officecash.nil?
		  officecash.value = officecash.value.to_i + val
		  officecash.save
		end
	end
	
	def add_eventlog event_id, name

		event = Event.find(event_id) rescue nil

		if !event.nil?
			note = name + ' oleh ' + current_user.username rescue 'admin'
			Eventlog.create(event_id: event_id, user_id: current_user.id, name: name, note: note)
		end

	end

	def get_customer_estimation customer_id, office_id, startdate, enddate

		offset = Setting.find_by_name('Offset Estimasi').to_i rescue 200000
		customer_35 = Customer.active.where("name ~* '.*Molindo.*' or name ~* '.*Aman jaya.*' or name ~* '.*Acidatama.*'").pluck(:id)

		startdate = startdate
		startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if startdate.nil?
		enddate = enddate
		enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if enddate.nil?

		total_estimation = 0
		eventsa = Event.active.where("start_date BETWEEN ? AND ?", startdate.to_date, enddate.to_date).order(:start_date)
		eventsa = eventsa.includes(:route).where("office_id = ? AND customer_id = ?", office_id, customer_id).map do |event|
			route = event.route
			price_per = route.price_per.to_i rescue 0
			price_per_type = route.price_per_type rescue 'KG'
			quantity = event.invoicetrain ? (event.qty.to_i * 2) : event.qty.to_i rescue 0
	
			quantity = event.qty.to_i rescue 0
			event_price_per_type = event.price_per_type rescue 'KG'
			event_tonage = event.estimated_tonage.to_i rescue 0 
	
			if price_per >= offset
			  estimation = quantity * price_per
			elsif customer_35.include? event.customer_id
			  estimation = quantity * 20000 * price_per
			else
			  estimation = quantity * event_tonage *  price_per
			end

			total_estimation += estimation
		end

		return to_currency(total_estimation)

	end

	# def updatecashdailylogold total, date = nil, officecash = 0
	# 	date = Date.today.strftime('%d-%m-%Y') if date.nil?

	# 	if date == Date.today.strftime('%d-%m-%Y')
	# 		cashdailylog = Cashdailylog.where("date = ?", date.to_date).first rescue nil
	# 		cashdailylog = Cashdailylog.new if cashdailylog.nil?
			
	# 		cashdailylog.date = date
	# 	 	cashdailylog.total = cashdailylog.total + total
	# 	 	cashdailylog.save
	# 	else
	# 		cashdailylog = Cashdailylog.where("date >= ?", date.to_date) 
	# 		if cashdailylog.any?
	# 			cashdailylog.each do |log|
	# 				log.total += total
	# 		 		log.save
	# 		 	end
	# 		end
	# 	end
	# end

	def updatecashdailylog total, date = nil, officecash = 0
		date = Date.today.strftime('%d-%m-%Y') if date.nil?

		cashdailylogs = Cashdailylog.where("date >= ?", date.to_date) 

		todaylog = Cashdailylog.where("date = ?", date.to_date).first rescue nil
		if todaylog.nil?
			todaylog = Cashdailylog.new 
			todaylog.date = date
			todaylog.total = officecash.to_i
			todaylog.save
		 	
		 	cashdailylogs << todaylog
	 	end

		cashdailylogs.each do |log|
			log.total += total
	 		log.save
	 	end
		
	end 

	def updatebudget val
		officecash = Setting.find_by_name("Budget Pembelian") rescue nil
		if !officecash.nil?
		  officecash.value = officecash.value.to_i + val
		  officecash.save
		end
	end	

	def checkavailableofficecash(val)
		officecash = Setting.find_by_name("Saldo Kas Kantor") rescue nil
		if !officecash.nil? and officecash.value.to_i > val
			return true
		else
			return false
		end	
	end

	def checkavailablebudget(val)
		budget = Setting.find_by_name("Budget Pembelian") rescue nil
		if !budget.nil? and budget.value.to_i > val
			return true
		else
			return false
		end
	end	

	def moneytowordsrupiah(val)
		scaleNumber = ["", "ribu", "juta", "milyar"]
		currencyText = "rupiah"
		centText = "koma"
		fraction = val - val.truncate
		
		if val == 0
			return "nol " + currencyText
		else
			positive = (val.truncate).abs
			digitgroups = Array.new(4)
			
			(0..3).each do |i|
				digitgroups[i] = positive % 1000
				positive = positive / 1000
			end

			textgroups = Array.new(4) 
			(0..3).each do |i|
				textgroups[i] = ThreeDigitGroupsToWords digitgroups[i].to_i
			end

			combined = textgroups[0]

			(1..3).each do |i|
				if digitgroups[i] != 0
					if i == 1 and digitgroups[i] == 1
						prefix = "seribu"
					else
						prefix = textgroups[i] + " " + scaleNumber[i]
					end

					if combined.length != 0
						prefix += " "
					end

					combined = prefix + combined 
				end
			end
		end

		if fraction > 0
			cent = (fraction * 100).round
			cent = ThreeDigitGroupsToWords cent

			return combined + " " + centText + " " + cent + " " + currencyText
		else
			return combined + " " + currencyText
		end 
	end
	
	def ThreeDigitGroupsToWords threeDigit
		smallNumber = ["nol", "satu", "dua", "tiga", "empat", "lima", "enam", "tujuh", "delapan", "sembilan", "sepuluh", "sebelas", "dua belas", "tiga belas","empat belas", "lima belas", "enam belas", "tujuh belas", "delapan belas", "sembilan belas"]
		tens = ["", "", "dua puluh", "tiga puluh", "empat puluh", "lima puluh", "enam puluh", "tujuh puluh", "delapan puluh", "sembilan puluh"]
		
		groupText = ""

		hundreds = threeDigit / 100
		tensUnit = threeDigit % 100

		if hundreds != 0
			if hundreds == 1
				groupText = "seratus"
			else
				groupText += smallNumber[hundreds] + ' ratus'
			end

			if tensUnit != 0
				groupText += " "
			end
		end

		itens = tensUnit / 10
		units = tensUnit % 10

		if itens >= 2
			groupText += tens[itens]
			if units != 0
				groupText += " " + smallNumber[units]
			end
		elsif tensUnit != 0
			groupText += smallNumber[tensUnit]
		end
		
		return groupText
	end

	def getromenumber (input)
	    objreturn = ""

	    if input ==  1
	      objreturn = "I"
	    elsif input ==  2
	      objreturn = "II"
	    elsif input ==  3
	      objreturn = "III"
	    elsif input ==  4
	      objreturn = "IV"
	    elsif input ==  5
	      objreturn = "V"
	    elsif input ==  6
	      objreturn = "VI"
	    elsif input ==  7
	      objreturn = "VII"
	    elsif input ==  8
	      objreturn = "VIII"
	    elsif input ==  9
	      objreturn = "IX"
	    elsif input ==  10
	      objreturn = "X"
	    elsif input ==  11
	      objreturn = "XI"
	    elsif input ==  12
	      objreturn = "XII"
	    end
  	end

	def getlastday (input)
	    objreturn = ""

	    if input ==  "01"
	      objreturn = 31
	    elsif input ==  "02"
	      objreturn = 28
	    elsif input ==  "03"
	      objreturn = 31
	    elsif input ==  "04"
	      objreturn = 30
	    elsif input ==  "05"
	      objreturn = 31
	    elsif input ==  "06"
	      objreturn = 30
	    elsif input ==  "07"
	      objreturn = 31
	    elsif input ==  "08"
	      objreturn = 31
	    elsif input ==  "09"
	      objreturn = 30
	    elsif input ==  "10"
	      objreturn = 31
	    elsif input ==  "11"
	      objreturn = 30
	    elsif input ==  "12"
	      objreturn = 31
	    end
	end

end
