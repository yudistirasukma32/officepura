class ReceiptexpensesController < ApplicationController
	include ApplicationHelper
  include ActionView::Helpers::NumberHelper
	layout "application", :except => []
  before_filter :authenticate_user!, :set_section

	def set_section
		@section = "cashiers"
	end

	def new
		@errors = Hash.new
		@receiptexpense = Receiptexpense.new
		@officeexpense_id = params[:officeexpense_id]
		@officeexpense = Officeexpense.find(params[:officeexpense_id]) rescue nil
	end

	def create
		@errors = Hash.new
		@receiptexpense = Receiptexpense.new
		inputs = params[:receiptexpense]
		@officeexpense_id = inputs[:officeexpense_id]
		@officeexpense = Officeexpense.find(inputs[:officeexpense_id]) rescue nil

		if !@officeexpense.bankexpensegroup_id.nil?
			create_jurnal @officeexpense.id
		end

		if @officeexpense.expensetype == 'Kredit' && !checkavailableofficecash(inputs[:total].to_i)
			@errors["receiptexpense"] = 'Kas Harian gagal di tambah, uang kas tidak memenuhi.'
      		render :action => "new"
    	else
			@receiptexpense.officeexpense_id = @officeexpense.id
			@receiptexpense.officeexpensegroup_id = @officeexpense.officeexpensegroup_id
			@receiptexpense.expensetype = @officeexpense.expensetype
			@receiptexpense.total = @officeexpense.total
			@receiptexpense.user_id = current_user.id
			
			receipt_exist = Receiptexpense.where(:officeexpense_id => @officeexpense.id, :deleted => false).first rescue nil
			if receipt_exist.nil?
				@receiptexpense.save
	      		officecash @receiptexpense
				redirect_to(cashiers_url, :notice => 'Kas Harian sukses di tambah.')
			else
				redirect_to(cashiers_url)
			end
		end
	end

	def edit
		@errors = Hash.new
		@receiptexpense = Receiptexpense.find(params[:id]) rescue nil
	end

	def update
	    @errors = Hash.new
	    inputs = params[:receiptexpense]
	    @receipt = Receiptexpense.find(inputs[:receiptexpense_id]) rescue nil

	    past_date = @receipt.created_at.to_date.strftime('%d-%m-%Y')
	    if past_date != inputs[:created_at]
	      if @receipt.expensetype == 'Debit'
	        updatecashdailylog @receipt.total * -1, past_date
	      else
	      	updatecashdailylog @receipt.total, past_date
	      end

	      datestring = inputs[:created_at].split('-')
	
	      present_date = DateTime.new(datestring[2].to_i, datestring[1].to_i, datestring[0].to_i)
		  	if @receipt.expensetype == 'Debit'
	        updatecashdailylog @receipt.total, present_date.strftime('%d-%m-%Y')
	      else
	      	updatecashdailylog @receipt.total * -1, present_date.strftime('%d-%m-%Y')
	      end

	      @receipt.created_at = present_date
	      @receipt.save
	      redirect_to(cashiers_path, :notice => 'Kasir Kas No. ' + zeropad(inputs[:receiptexpense_id]) + ' sukses di tambah.')
	    else
	      redirect_to(cashiers_path)
	    end
	end

	def officecash expense, remove=false
	    if remove
	      if expense.expensetype == 'Debit'
	        updateofficecash expense.total * -1, expense.created_at.strftime('%d-%m-%Y')
	      else
	      	updateofficecash expense.total, expense.created_at.strftime('%d-%m-%Y')
	      end      
	    else
	      if expense.expensetype == 'Debit'
	        updateofficecash expense.total, expense.created_at.strftime('%d-%m-%Y') 
	      else
	      	updateofficecash expense.total * -1, expense.created_at.strftime('%d-%m-%Y')
	      end
	    end
	end

	def create_jurnal officeexpense_id
		@officeexpense = Officeexpense.find(officeexpense_id)
		# Create Journal
	    @bankexpense = Bankexpense.new
	    @bankexpense.enabled = true
	    @bankexpense.office_id = @officeexpense.office_id
	    @bankexpense.date = @officeexpense.date
	    @bankexpense.description = @officeexpense.description
	    @bankexpense.pettycashledger = true
	    	    
	    kas = Bankexpensegroup.where("UPPER(name) = ? ", 'KAS').first
	    if @officeexpense.expensetype == 'Kredit'
	      @bankexpense.debitgroup_id = @officeexpense.bankexpensegroup_id
	      @bankexpense.creditgroup_id = kas.id
	    else
	      @bankexpense.debitgroup_id = kas.id
	      @bankexpense.creditgroup_id = @officeexpense.bankexpensegroup_id
	    end
	    @bankexpense.total = @officeexpense.total

	    if @bankexpense.save
	      debit_to = Bankexpensegroup.find(@bankexpense.debitgroup_id) rescue nil
	      if !debit_to.nil?
	        debit_to.total += @bankexpense.total
	        debit_to.save
	        # updateofficecash @bankexpense.total, @bankexpense.date.strftime('%d-%m-%Y') if debit_to.name.upcase == 'KAS'
	      end

	      credit_to = Bankexpensegroup.find(@bankexpense.creditgroup_id) rescue nil
	      if !credit_to.nil?
	        credit_to.total -= @bankexpense.total
	        credit_to.save
	        # updateofficecash @bankexpense.total * -1, @bankexpense.date.strftime('%d-%m-%Y') if credit_to.name.upcase == 'KAS'
	      end
	    end
	    @officeexpense.bankexpense_id = @bankexpense.id

	    @officeexpense.transaction do
	    	@officeexpense.save
	    end
	end

	def destroy
		@receiptexpense = Receiptexpense.find(params[:id])
		
	    officecash @receiptexpense, true
	    @receiptexpense.deleted = true
	    @receiptexpense.deleteuser_id = current_user.id
	    @receiptexpense.save

	    destroy_jurnal @receiptexpense.officeexpense_id

	    redirect_to(cashiers_url)
	end

	def destroy_jurnal officeexpense_id
		@officeexpense = Officeexpense.find(officeexpense_id)

		if !@officeexpense.bankexpense_id.nil?
			@bankexpense = Bankexpense.find(@officeexpense.bankexpense_id)

			if @bankexpense
		      tmp_debit_to = Bankexpensegroup.find(@bankexpense.debitgroup_id) rescue nil
		      tmp_credit_to = Bankexpensegroup.find(@bankexpense.creditgroup_id) rescue nil
		      tmp_total = @bankexpense.total

		      # update old value
		      if !tmp_debit_to.nil?
		        tmp_debit_to.total -= tmp_total
		        tmp_debit_to.save
		      end

		      if !tmp_credit_to.nil?
		        tmp_credit_to.total += tmp_total
		        tmp_credit_to.save
		      end
		      @bankexpense.deleteuser_id = current_user.id
		    end
		    @bankexpense.deleted = true
		    @bankexpense.transaction do
			    @bankexpense.save
			end
		end
	end
end