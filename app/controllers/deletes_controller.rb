class DeletesController < ApplicationController
	include ApplicationHelper
  	include ActionView::Helpers::NumberHelper
	layout "application", :except => []
  	before_filter :authenticate_user!

	ID_GROUP_STOK = 7
  	ID_GROUP_HUTANGTOKO = 19
  	ID_GROUP_MANDIRITOKO = 86

  	ID_GROUP_PPH = 11
  	ID_GROUP_PPN = 10
  	ID_GROUP_PIUTANG = 6
  	ID_GROUP_PENDAPATAN = 22
  	ID_GROUP_MANDIRI = 5


	def action
		bankexpenses = Bankexpense.where("taxinvoice_id IS NOT NULL or productorder_id IS NOT NULL") rescue nil
		bankexpenses.each do |bankexpense|
			tmp_debit_to = Bankexpensegroup.find(bankexpense.debitgroup_id) rescue nil
		    tmp_credit_to = Bankexpensegroup.find(bankexpense.creditgroup_id) rescue nil
		    tmp_total = bankexpense.total

	      	# update old value
	      	if !tmp_debit_to.nil?
	        	tmp_debit_to.total -= tmp_total
	        	tmp_debit_to.save
	      	end

	      	if !tmp_credit_to.nil?
	        	tmp_credit_to.total += tmp_total
	        	tmp_credit_to.save
	      	end

	      	bankexpense.deleteuser_id = current_user.id
		    bankexpense.deleted = true
		    bankexpense.save
		end


		productorders = Productorder.where("date >= '2013-08-01' and deleted = false") rescue nil
		productorders.each do |productorder|
			totalbon = productorder.productorderitems.where(:bon => true).sum(:total)
			if totalbon > 0 
				@bankexpense = Bankexpense.where(:productorder_id => productorder.id, :debitgroup_id => ID_GROUP_STOK, :creditgroup_id => ID_GROUP_HUTANGTOKO, :deleted => false).first
		        @bankexpense = Bankexpense.new if @bankexpense.nil?
		        
		        @bankexpense.debitgroup_id = ID_GROUP_STOK
		        @bankexpense.creditgroup_id = ID_GROUP_HUTANGTOKO
		        @bankexpense.productorder_id = productorder.id
		        @bankexpense.total = totalbon
				@bankexpense.description = "Pembelian Bon. #" + zeropad(productorder.id)
		        @bankexpense.date = productorder.date
		        
		        if @bankexpense.save
		          debit_to = Bankexpensegroup.find(@bankexpense.debitgroup_id) rescue nil
		          if !debit_to.nil?
		            debit_to.total += @bankexpense.total
		            debit_to.save
		          end

		          credit_to = Bankexpensegroup.find(@bankexpense.creditgroup_id) rescue nil
		          if !credit_to.nil?
		            credit_to.total -= @bankexpense.total
		            credit_to.save
		          end
		        end
		    end
		end

		paymentchecks = Paymentcheck.where("date >= '2013-08-01' and deleted = false") rescue nil
		paymentchecks.each do |paymentcheck|
			productorders = Productorder.where("deleted = false and id in (select productorder_id from productorderitems where paymentcheck_id = ?)", paymentcheck.id)

			productorders.each do |productorder|
				totalbon = productorder.productorderitems.where(:bon => true).sum(:total)
				if totalbon > 0 
					@bankexpense = Bankexpense.where(:productorder_id => productorder.id, :debitgroup_id => ID_GROUP_HUTANGTOKO, :creditgroup_id => ID_GROUP_MANDIRITOKO, :deleted => false).first
			        @bankexpense = Bankexpense.new if @bankexpense.nil?
			        
			        @bankexpense.debitgroup_id = ID_GROUP_HUTANGTOKO
			        @bankexpense.creditgroup_id = ID_GROUP_MANDIRITOKO
			        @bankexpense.productorder_id = productorder.id
			        @bankexpense.total = totalbon
					@bankexpense.description = "Pelunasan Giro Pembelian Bon #" + zeropad(productorder.id)
			        @bankexpense.date = paymentcheck.date
			        
			        
			        if @bankexpense.save
			          debit_to = Bankexpensegroup.find(@bankexpense.debitgroup_id) rescue nil
			          if !debit_to.nil?
			            debit_to.total += @bankexpense.total
			            debit_to.save
			          end

			          credit_to = Bankexpensegroup.find(@bankexpense.creditgroup_id) rescue nil
			          if !credit_to.nil?
			            credit_to.total -= @bankexpense.total
			            credit_to.save
			          end
			        end
			    end
			end
		end

		taxinvoices = Taxinvoice.where("date >= '2013-08-01' and deleted = false") rescue nil
		taxinvoices.each do |taxinvoice|
			description = "Invoice " + taxinvoice.long_id
          
			#record bank pendapatan 
			@bankexpensependapatan = Bankexpense.where(:taxinvoice_id => taxinvoice.id,  :creditgroup_id => ID_GROUP_PENDAPATAN, :deleted => false).first
			@bankexpensependapatan = Bankexpense.new if @bankexpensependapatan.nil?
			@bankexpensependapatan.creditgroup_id = ID_GROUP_PENDAPATAN
			@bankexpensependapatan.taxinvoice_id = taxinvoice.id
			@bankexpensependapatan.total = taxinvoice.total.to_f - taxinvoice.gst_tax.to_f + taxinvoice.price_tax.to_f
			@bankexpensependapatan.description = description
			@bankexpensependapatan.date = taxinvoice.date
			if @bankexpensependapatan.save
				credit_to = Bankexpensegroup.find(ID_GROUP_PENDAPATAN) rescue nil
				if !credit_to.nil?
				  credit_to.total -= @bankexpensependapatan.total
				  credit_to.save
				end
			end

			#record bank ppn 
			if taxinvoice.gst_tax.to_i > 0
				@bankexpenseppn = Bankexpense.where(:taxinvoice_id => taxinvoice.id,  :creditgroup_id => ID_GROUP_PPN, :deleted => false).first
				@bankexpenseppn = Bankexpense.new if @bankexpenseppn.nil?
				@bankexpenseppn.creditgroup_id = ID_GROUP_PPN
				@bankexpenseppn.taxinvoice_id = taxinvoice.id
				@bankexpenseppn.total = taxinvoice.gst_tax.to_i
				@bankexpenseppn.description = description
				@bankexpenseppn.date = taxinvoice.date
				if @bankexpenseppn.save
					credit_to = Bankexpensegroup.find(ID_GROUP_PPN) rescue nil
					if !credit_to.nil?
						credit_to.total -= @bankexpenseppn.total
						credit_to.save
					end
				end
			end 

			#record bank pph
			if taxinvoice.price_tax.to_i > 0
				@bankexpensepph = Bankexpense.where(:taxinvoice_id => taxinvoice.id,  :debitgroup_id => ID_GROUP_PPH, :deleted => false).first
				@bankexpensepph = Bankexpense.new if @bankexpensepph.nil?
				@bankexpensepph.debitgroup_id = ID_GROUP_PPH
				@bankexpensepph.taxinvoice_id = taxinvoice.id
				@bankexpensepph.total = taxinvoice.price_tax.to_i
				@bankexpensepph.description = description
				@bankexpensepph.date = taxinvoice.date
				if @bankexpensepph.save
					debit_to = Bankexpensegroup.find(ID_GROUP_PPH) rescue nil
					if !debit_to.nil?
						debit_to.total += @bankexpensepph.total
						debit_to.save
					end
				end
			end 

			#record bank piutang
			@bankexpensepiutang = Bankexpense.where(:taxinvoice_id => taxinvoice.id,  :debitgroup_id => ID_GROUP_PIUTANG, :deleted => false).first
			@bankexpensepiutang = Bankexpense.new if @bankexpensepiutang.nil?
			@bankexpensepiutang.debitgroup_id = ID_GROUP_PIUTANG
			@bankexpensepiutang.taxinvoice_id = taxinvoice.id
			@bankexpensepiutang.total = taxinvoice.total
			@bankexpensepiutang.description = description
			@bankexpensepiutang.date = taxinvoice.date
			if @bankexpensepiutang.save
				debit_to = Bankexpensegroup.find(ID_GROUP_PIUTANG) rescue nil
				if !debit_to.nil?
					debit_to.total += @bankexpensepiutang.total
					debit_to.save
				end
			end

			if !taxinvoice.paiddate.nil?
				#record bank pembayaran
				@bankexpensebayar = Bankexpense.where(:taxinvoice_id => taxinvoice.id, :creditgroup_id => ID_GROUP_PIUTANG ,:debitgroup_id => ID_GROUP_MANDIRI, :deleted => false).first
				@bankexpensebayar = Bankexpense.new if @bankexpensebayar.nil?
				@bankexpensebayar.debitgroup_id = ID_GROUP_MANDIRI
				@bankexpensebayar.creditgroup_id = ID_GROUP_PIUTANG
				@bankexpensebayar.taxinvoice_id = taxinvoice.id
				@bankexpensebayar.total = taxinvoice.total
				@bankexpensebayar.description = "Pelunasan Invoice " +  taxinvoice.long_id
				@bankexpensebayar.date = taxinvoice.paiddate
				if @bankexpensebayar.save
					debit_to = Bankexpensegroup.find(@bankexpensebayar.debitgroup_id) rescue nil
					if !debit_to.nil?
					  debit_to.total += @bankexpensebayar.total
					  debit_to.save
					end

					credit_to = Bankexpensegroup.find(@bankexpensebayar.creditgroup_id) rescue nil
					if !credit_to.nil?
					  credit_to.total -= @bankexpensebayar.total
					  credit_to.save
					end
				end
			end
		end

		redirect_to "/masters"
	end

	def bankexpense
		bankexpenses = Bankexpense.where("productorder_id IS NOT NULL and debitgroup_id = ? and deleted = false", ID_GROUP_HUTANGTOKO) rescue nil
		bankexpenses.each do |bankexpense|
			bank = Bankexpense.where(:productorder_id => bankexpense.productorder_id, :creditgroup_id => ID_GROUP_HUTANGTOKO, :deleted => false).first rescue nil
			if bank
				bankexpense.bankexpense_id = bank.id
				bankexpense.save
			end
		end

		bankexpenses = Bankexpense.where("taxinvoice_id IS NOT NULL and creditgroup_id = ? and deleted = false", ID_GROUP_PIUTANG) rescue nil
		bankexpenses.each do |bankexpense|
			bank = Bankexpense.where(:taxinvoice_id => bankexpense.taxinvoice_id, :debitgroup_id => ID_GROUP_PIUTANG, :deleted => false).first rescue nil
			if bank
				bankexpense.bankexpense_id = bank.id
				bankexpense.save
			end
		end

		redirect_to "/masters"
	end

	def money
		render :json => {:words => moneytowordsrupiah(12341321500)}.to_json;
	end

	def receiptreturn
		receiptreturns = Receiptreturn.active

		receiptreturns.each do |receiptreturn|
			receiptreturn.invoicereturn_id = receiptreturn.invoice.invoicereturns.active.first.id if !receiptreturn.invoice.invoicereturns.active.first.nil?
			receiptreturn.save
		end

		redirect_to "/masters"
	end
end