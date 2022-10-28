class PaymentchecksController < ApplicationController
	include ApplicationHelper
	layout "application"
  	before_filter :authenticate_user!, :set_section
  	# ID_GROUP_MANDIRITOKO = 86
  	ID_GROUP_HUTANGTOKO = 19

	def set_section
		@section = "transactions2"
		@where = "paymentchecks"
	end

	def index
		@suppliers = Supplier.active.order(:name)
	end

	def indexchecks
		@month = params[:month]
	    @month = "%02d" % Date.today.month.to_s if @month.nil?
	    @year = params[:year]
	    @year = Date.today.year if @year.nil?
    	@paymentchecks = Paymentcheck.where("to_char(date, 'MM-YYYY') = ?", "#{@month}-#{@year}").order(:id)
    	respond_to :html
	end

	def new
		@paymentcheck = Paymentcheck.new
		@paymentcheck.date = Date.today.strftime('%d-%m-%Y')
		@paymentcheck.supplier_id = params[:supplier_id]

		@supplier_id = params[:supplier_id]
		@supplier = Supplier.find(params[:supplier_id])

		@productorders = Productorder.where("deleted = false AND id in (SELECT productorder_id FROM productorderitems where supplier_id = ? AND bon = true AND paymentcheck_id IS NULL)", @supplier_id).order(:date)
	end

	def create
		inputs= params[:paymentcheck]
		@paymentcheck = Paymentcheck.new
		@productorders = Productorder.where("deleted = false AND id in (SELECT productorder_id FROM productorderitems where supplier_id = ? AND bon = true AND paymentcheck_id IS NULL)", inputs[:supplier_id])
		@paymentcheck.supplier_id = inputs[:supplier_id]
		@paymentcheck.date = inputs[:date]
		@paymentcheck.check_no = inputs[:check_no]

		total = 0

		if @paymentcheck.save
			@productorders.each do |productorder|
				if inputs["cb_" + productorder.id.to_s] == 'on'
					
					productorder.productorderitems.each do |item|
						item.paymentcheck_id = @paymentcheck.id
						total += item.total

						item.save
					end

					createbankexpenserecord productorder.id, ID_GROUP_HUTANGTOKO, params[:bank_id], inputs[:date], inputs[:check_no]
				end
			end

			@paymentcheck.total = total
			@paymentcheck.save
		end
		redirect_to(paymentchecks_url, :notice => "Data Giro sukses disimpan.")
	end

	def edit
	end

	def update
	end

	def destroy
		@paymentcheck = Paymentcheck.find(params[:id])
		
		@productorders = Productorder.where("deleted = false AND id in (SELECT productorder_id from productorderitems where paymentcheck_id = ?)", @paymentcheck.id)
		if @productorders.any?
			@productorders.each do |productorder|
				destroybankexpenserecord productorder.id, ID_GROUP_HUTANGTOKO
				# destroybankexpenserecord productorder.id, ID_GROUP_HUTANGTOKO, ID_GROUP_MANDIRITOKO
			end
		end

		@paymentcheck.productorderitems.each do |item|
			item.paymentcheck_id = nil
			item.save
		end
		
		@paymentcheck.deleted = true
		@paymentcheck.save

		redirect_to(paymentchecks_url)
	end

	def createbankexpenserecord productorder_id, debitgroup_id, creditgroup_id, date, ket
	    @productorder = Productorder.find(productorder_id) rescue nil
	    if @productorder
	    	totalbon = @productorder.productorderitems.where(:bon => true).sum(:total)

	    	if totalbon > 0
		        @bankexpense = Bankexpense.where(:productorder_id => productorder_id, :debitgroup_id => debitgroup_id, :creditgroup_id => creditgroup_id, :deleted => false).first
		        
		        needupdate = @bankexpense.nil? ? false : true

		        @bankexpense = Bankexpense.new if @bankexpense.nil?
		        
		        @bankexpense.debitgroup_id = debitgroup_id
		        @bankexpense.creditgroup_id = creditgroup_id
		        @bankexpense.productorder_id = productorder_id
		        @bankexpense.description = "Pembayaran Bon Pembelian #" + zeropad(@productorder.id) + ", " + ket
		        @bankexpense.date = date
		        
		        if needupdate
		          debit_to = Bankexpensegroup.find(@bankexpense.debitgroup_id) rescue nil
		          if !debit_to.nil?
		            debit_to.total -= @bankexpense.total
		            debit_to.save
		          end

		          credit_to = Bankexpensegroup.find(@bankexpense.creditgroup_id) rescue nil
		          if !credit_to.nil?
		            credit_to.total += @bankexpense.total
		            credit_to.save
		          end
		        end

		        @bankexpense.total = totalbon

		        bank = Bankexpense.where(:productorder_id => @bankexpense.productorder_id, :creditgroup_id => debitgroup_id, :deleted => false).first rescue nil
				if bank
					@bankexpense.bankexpense_id = bank.id
				end
		        
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

  	def destroybankexpenserecord productorder_id, debitgroup_id
  		bankexpenses = Bankexpense.where(:productorder_id => productorder_id, :debitgroup_id => debitgroup_id, :deleted => false)
  		if bankexpenses.any?
  			bankexpenses.each do |bankexpense|
  				bankexpense.deleted = true
  				bankexpense.deleteuser_id = current_user.id
  				if bankexpense.save
  					if !bankexpense.debitgroup_id.nil?
	  					debit_to = Bankexpensegroup.find(bankexpense.debitgroup_id) rescue nil
				        if !debit_to.nil?
				            debit_to.total -= bankexpense.total
				            debit_to.save
				        end
				    end

				    if !bankexpense.creditgroup_id.nil?
				        credit_to = Bankexpensegroup.find(bankexpense.creditgroup_id) rescue nil
				        if !credit_to.nil?
				            credit_to.total += bankexpense.total
				            credit_to.save
				        end
				    end
  				end
  			end
  		end
	end
end