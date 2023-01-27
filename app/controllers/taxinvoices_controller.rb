require 'roo'
class TaxinvoicesController < ApplicationController
	include ApplicationHelper
  include ActionView::Helpers::NumberHelper
	layout "application", :except => [:gettaxinvoiceitems]
  protect_from_forgery :except => [:updateitems, :updatepayment, :downpayment, :canceldownpayment, :transfer]
  before_filter :authenticate_user!, :set_section

  ID_GROUP_PPH = 11
  ID_GROUP_PPN = 10
  ID_GROUP_PIUTANG = 6
  ID_GROUP_PENDAPATAN = 22
  ID_GROUP_MANDIRI = 5
  ID_GROUP_DOWNPAYMENT = 96

  $globalMonth = "%02d" % Date.today.month.to_s
  $globalYear = Date.today.year
  $globalCustomer_id = ''

  def set_section
    @section = "transactions2"
    @where = "taxinvoices"
  end

  def index
    @section = "taxinvoices"
    @where = "taxinvoices"
    @month = params[:month]
    @month = "%02d" % Date.today.month.to_s if @month.nil?
    @year = params[:year]
    @year = Date.today.year if @year.nil?

    @customer = Customer.find(params[:customer_id]) rescue nil
    @customer_id = @customer.id if @customer

    $globalMonth = @month
    $globalYear = @year
    $globalCustomer_id = @customer_id

    @taxinvoices = Taxinvoice.active
    @taxinvoices = @customer.taxinvoices.active if @customer
    @taxinvoices = @taxinvoices.where("to_char(date, 'MM-YYYY') = ?", "#{@month}-#{@year}").order(:long_id)
     
    if params[:process] == 'payment'
      @taxinvoices.each do |taxinvoice|
        if params["cb_" + taxinvoice.id.to_s] == 'on'
          if taxinvoice.paiddate.nil?
            taxinvoice.paiddate = params[:paiddate]
            taxinvoice.save

            createbankexpenserecord taxinvoice.id, false
          end
        end
      end
    end

    respond_to :html
  end

  def new
    @errors = Hash.new
    @taxinvoice = Taxinvoice.new
    @taxinvoice.date = Date.today.strftime('%d-%m-%Y')
    @customer = Customer.find(params[:customer_id]) rescue nil
    @taxinvoice.period_start = Date.today.strftime('%d-%m-%Y')
    @taxinvoice.period_end = Date.today.strftime('%d-%m-%Y')
    @taxinvoice.price_by = 'is_net'
    @taxinvoice.user_id = current_user.id
    @needupdate = false
    @taxinvoice.sentdate = params[:sentdate]

     @customerlist = Customer.find_by_sql("Select distinct c.* from customers c inner join invoices iv on c.id = iv.customer_id " +
                                     "where iv.id in (Select t.invoice_id from taxinvoiceitems t where money(t.total) > money(0) and taxinvoice_id is null) order by c.name")

    if @customer
      romenumber = getromenumber (Date.today.month.to_i)
      @taxinvoiceitems = @customer.taxinvoiceitems.where("taxinvoice_id is null AND money(total) > money(0) AND rejected = false").order(:date, :sku_id)
      @taxinvoice.period_start = @customer.taxinvoiceitems.where(:taxinvoice_id => nil).minimum(:date) || Date.today.strftime('%d-%m-%Y')
      @taxinvoice.period_end = @customer.taxinvoiceitems.where(:taxinvoice_id => nil).maximum(:date) || Date.today.strftime('%d-%m-%Y')
      @long_id = Taxinvoice.where("to_char(date, 'MM-YYYY') = ?", Date.today.strftime('%m-%Y')).order("ID DESC").first.long_id[0,3].to_i + 1 rescue nil || '01'
      @long_id = ("%04d" % @long_id.to_s) + ' / TGH / PURA / ' + romenumber + ' / ' + Date.today.year.to_s 

      if params[:update] == 'true'
        @taxinvoiceitems.each do |item|
          item.price_per = item.invoice.route.price_per.to_f
          if item.is_gross 
            item.total = item.weight_gross.to_i * item.price_per.to_f
          elsif item.is_wholesale
            item.total = item.wholesale_price.to_f
          else
            item.total = item.weight_net.to_i * item.price_per.to_f
          end
          item.save
        end
      end

      @taxinvoiceitems.each do |item|
        if item.price_per.to_f != item.invoice.route.price_per.to_f
          @needupdate = true
          break
        end
      end

    end

    @strPeriod = ""
    if !@taxinvoice.period_start.nil? and !@taxinvoice.period_end.nil?
      if @taxinvoice.period_start == @taxinvoice.period_end
        @strPeriod = @taxinvoice.period_start.strftime('%d-%m-%Y')
      else
        @strPeriod = @taxinvoice.period_start.strftime('%d-%m-%Y') + "s/d" + @taxinvoice.period_end.strftime('%d-%m-%Y')
      end
    end
  end

  def edit
    @errors = Hash.new
    @taxinvoice = Taxinvoice.find(params[:id])
    # render json: @taxinvoice
    # return false
    @customerlist = Customer.find_by_sql("Select distinct c.* from customers c inner join invoices iv on c.id = iv.customer_id " +
                                     "where iv.id in (Select t.invoice_id from taxinvoiceitems t where t.total > '0.00') order by c.name")

    @customer = @taxinvoice.customer
    @taxinvoiceitems = @taxinvoice.taxinvoiceitems.order(:date, :sku_id)
    @long_id = @taxinvoice.long_id
    @process = "edit"
    @needupdate = false
    @taxinvoice.sentdate = params[:sentdate] if params[:sentdate].present?

    if params[:update] == 'true'
      @taxinvoiceitems.each do |item|
        item.price_per = item.invoice.route.price_per.to_f
        if item.is_gross 
          item.total = item.weight_gross.to_i * item.price_per.to_f
        elsif item.is_wholesale
          item.total = item.wholesale_price.to_f
        else
          item.total = item.weight_net.to_i * item.price_per.to_f
        end
        item.save
      end
      subtotal = @taxinvoice.taxinvoiceitems.sum(:total)
      extra_cost = @taxinvoice.extra_cost.to_f
      subtotal += extra_cost

      insurance_cost += @taxinvoice.insurance_cost.to_i
      subtotal -=insurance_cost
        
        #ppn_new
        ppn = Setting.where(name: 'ppn')
        ppn = ppn.blank? ? 10 : ppn[0].value
      
      @taxinvoice.gst_tax = @taxinvoice.gst_tax.to_f > 0 ? subtotal.to_f * (ppn.to_f / 100) : 0
      @taxinvoice.price_tax = @taxinvoice.price_tax.to_f > 0 ? subtotal.to_f * 0.02 : 0
      
      @taxinvoice.total = subtotal.to_f + @taxinvoice.gst_tax.to_f - @taxinvoice.price_tax.to_f

      @taxinvoice.user_id = current_user.id
      @taxinvoice.save

    end

    @taxinvoiceitems.each do |item|
      if item.price_per.to_f != item.invoice.route.price_per.to_f
        @needupdate = true
        break
      end
    end

    @strPeriod = ""
    if !@taxinvoice.period_start.nil? and !@taxinvoice.period_end.nil?
      if @taxinvoice.period_start == @taxinvoice.period_end
        @strPeriod = @taxinvoice.period_start.strftime('%d-%m-%Y')
      else
        @strPeriod = @taxinvoice.period_start.strftime('%d-%m-%Y') + " s/d " + @taxinvoice.period_end.strftime('%d-%m-%Y')
      end
    end

    
  end

  def updateitems
    # render json: params
    # return false
    @errors = Hash.new
    @customer = Customer.find(params[:customer_id]) rescue nil

    customer_wholesaleprice = @customer.wholesale_price if !@customer.nil?
    
    if @customer
      if params[:process] == "edit"
        @taxinvoice = Taxinvoice.find(params[:id])
        #@taxinvoiceitems = @taxinvoice.taxinvoiceitems
        @taxinvoiceitems = @customer.taxinvoiceitems.where("taxinvoice_id is null AND total > '$0.00'").order(:date)
        @taxinvoice.long_id = params[:long_id]
      else
        romenumber = getromenumber (Date.today.month.to_i)
        @taxinvoiceitems = @customer.taxinvoiceitems.where("taxinvoice_id is null AND money(total) > money(0) AND rejected = false").order(:date)
        @long_id = Taxinvoice.where("to_char(date, 'MM-YYYY') = ?", Date.today.strftime('%m-%Y')).order("ID DESC").first.long_id[0,3].to_i + 1 rescue nil || '01'
        @long_id = ("%04d" % @long_id.to_s) + ' / TGH / PURA / ' + romenumber + ' / ' + Date.today.year.to_s 
        @taxinvoice = Taxinvoice.new
        @taxinvoice.long_id = params[:long_id]
      end

      if !params[:customer_npwp].nil? and @customer.npwp != params[:customer_npwp]
        @customer.npwp = params[:customer_npwp]
        @customer.save
      end

      @taxinvoice.customer_id = @customer.id
      @taxinvoice.ship_name = params[:ship_name]
      @taxinvoice.date = params[:date]
      @taxinvoice.duedate = @customer.terms_of_payment_in_days.nil? ? Date.today + 2.months : Date.today + @customer.terms_of_payment_in_days.to_i.days
      @taxinvoice.product_name = params[:product_name]
      @taxinvoice.spk_no = params[:spk_no]
      @taxinvoice.po_no = params[:po_no]
      @taxinvoice.tank_name = params[:tank_name]
      @taxinvoice.spo_no = params[:spo_no]
      @taxinvoice.sto_no = params[:sto_no]
      @taxinvoice.so_no = params[:so_no]
      @taxinvoice.do_no = params[:do_no]
      @taxinvoice.confirmeddate = params[:confirmeddate]
      @taxinvoice.waybill = params[:waybill]
      @taxinvoice.extra_cost = params[:extra_cost].to_i
      @taxinvoice.extra_cost_info = params[:extra_cost_info]
      # @taxinvoice.total_in_words = params[:total_in_words]
      @taxinvoice.description = params[:description]
      @taxinvoice.price_by = params[:price_by]
      @taxinvoice.is_weightlost = params[:is_weightlost] == "Yes" ? true : false
      @taxinvoice.sentdate = params[:sentdate]
      @taxinvoice.insurance_cost = params[:insurance_cost]
      @taxinvoice.remarks = params[:remarks]
      @taxinvoice.claim_cost = params[:claim_cost]
      @taxinvoice.user_id = current_user.id
      @taxinvoice.save
      
      @taxinvoiceitems.each do |taxinvoiceitem|
        if params["cb_" + taxinvoiceitem.id.to_s] == 'on'
          taxinvoiceitem.taxinvoice_id = @taxinvoice.id
          taxinvoiceitem.wholesale_price = customer_wholesaleprice
          taxinvoiceitem.save
        else
          taxinvoiceitem.taxinvoice_id = nil
          taxinvoiceitem.save 
        end
      end

      @taxinvoice.taxinvoiceitems.each do |taxinvoiceitem|
        if params["cb_" + taxinvoiceitem.id.to_s] == 'on'
          taxinvoiceitem.total = taxinvoiceitem.wholesale_price
          taxinvoiceitem.date = params["date_" + taxinvoiceitem.id.to_s] if !params["date_" + taxinvoiceitem.id.to_s].blank?
          taxinvoiceitem.sku_id = params["sku_" + taxinvoiceitem.id.to_s] if !params["sku_" + taxinvoiceitem.id.to_s].blank?
          taxinvoiceitem.weight_gross = params["gross_" + taxinvoiceitem.id.to_s] if !params["gross_" + taxinvoiceitem.id.to_s].blank?

          if params["qty_" + taxinvoiceitem.id.to_s].to_i > 0
            taxinvoiceitem.weight_net = params["qty_" + taxinvoiceitem.id.to_s]

            total = 0

            taxinvoiceitem.is_wholesale = false
            taxinvoiceitem.is_gross = false
            taxinvoiceitem.is_net = false

            if params[:price_by] == 'is_wholesale'
              taxinvoiceitem.is_wholesale = true
              total = customer_wholesaleprice.to_f
            elsif params[:price_by] == 'is_gross'
              taxinvoiceitem.is_gross = true
              if taxinvoiceitem.price_per >= 300000
                total = taxinvoiceitem.price_per.to_f
              else
                total = params["gross_" + taxinvoiceitem.id.to_s].to_i * taxinvoiceitem.price_per.to_f
              end
            else
              taxinvoiceitem.is_net = true
              if taxinvoiceitem.price_per >= 300000
                total = taxinvoiceitem.price_per.to_f
              else
                total = params["qty_" + taxinvoiceitem.id.to_s].to_i * taxinvoiceitem.price_per.to_f
              end
            end

            taxinvoiceitem.total = total

          end
          
          taxinvoiceitem.save
        else
          taxinvoiceitem.taxinvoice_id = nil
          taxinvoiceitem.save 
        end
      end
      
      #update total and tax
      period_start = @taxinvoice.taxinvoiceitems.minimum("date")
      period_end =  @taxinvoice.taxinvoiceitems.maximum("date")
      subtotal = @taxinvoice.taxinvoiceitems.sum(:total)

      # subtotal = subtotal.to_i
      extra_cost = @taxinvoice.extra_cost.to_f
      
      @taxinvoice.period_start = period_start
      @taxinvoice.period_end = period_end

        #ppn_new
        ppn = Setting.where(name: 'ppn')
        ppn = ppn.blank? ? 10 : ppn[0].value    
        
      subtotal += extra_cost
      ppn_percentage = params[:gst_tax].to_f
      if ppn_percentage > 0
        @taxinvoice.gst_tax = subtotal.to_f * (ppn_percentage.to_f / 100)
      else
        @taxinvoice.gst_tax = 0
      end
      
      @taxinvoice.gst_percentage = ppn_percentage
      if params[:price_tax] == "Yes"
            @taxinvoice.price_tax = subtotal.to_f * 0.02 
      else
        @taxinvoice.price_tax = 0
      end
      
      total = subtotal.to_f + @taxinvoice.gst_tax.to_f - @taxinvoice.price_tax.to_f

      total = total - @taxinvoice.insurance_cost - @taxinvoice.claim_cost
      
      if params[:pembulatan].present?
        total = total.round()
      end

      @taxinvoice.total = total
      @taxinvoice.total_in_words = moneytowordsrupiah(@taxinvoice.total)
 
      @taxinvoice.save

      createbankexpenserecord @taxinvoice.id, true

      # if params[:pembulatan].present?
      #   render json: {
      #     subtotal: subtotal,
      #     pph: @taxinvoice.price_tax ,
      #     grandtotal: @taxinvoice.total()
      #   }
      #   return false
      # end
      # render json: 
      # return false
      redirect_to(taxinvoices_url, :notice => "Data Invoice untuk pelanggan<br /><strong class='yellow'>#{@customer.name}</strong><br />sukses disimpan.".html_safe)
    end
  end

  def print
    @taxinvoice = Taxinvoice.find(params[:id])
    grandtotal = @taxinvoice.total - @taxinvoice.total.to_i 
    @is_pembulatan = (grandtotal == 0)
    # @decimal_place = is_pembulatan ? 0 : 2
    # render json: {
    #   totalitem: total == 0,
    #   gst_tax: gst_tax == 0,
    #   price_tax: price_tax == 0,
    #   grandtotal: grandtotal == 0,
    #   is_pembulatan: @is_pembulatan
    # }
    # return false
    respond_to :html
  end

  def printreceipt
    @taxinvoice = Taxinvoice.find(params[:id])
    grandtotal = @taxinvoice.total - @taxinvoice.total.to_i 
    @is_pembulatan = (grandtotal == 0)
    # @decimal_place = is_pembulatan ? 0 : 2
    # render json: {
    #   totalitem: total == 0,
    #   gst_tax: gst_tax == 0,
    #   price_tax: price_tax == 0,
    #   grandtotal: grandtotal == 0,
    #   is_pembulatan: @is_pembulatan
    # }
    # return false
    respond_to :html
  end  

  def gettaxinvoiceitems
    @customer = Customer.find(params[:customer_id]) rescue nil
    @taxinvoiceitems = Taxinvoiceitem.where(:customer_id => params[:customer_id], :taxinvoice_id => nil).where("date > current_date - interval '1 year'").order(:date)

    if params[:is_wholesale] == 'true'
      @taxinvoiceitems.each do |item|
        item.wholesale_price = @customer.wholesale_price
        item.total = @customer.wholesale_price
        item.is_wholesale = true
      end
    end
    render :json => {:success => true, :html => render_to_string(:partial => "taxinvoices/additionalitem"), :layout => false}.to_json; 
  end

  def payment
    @defaultBankValue = 5
    @defaultPiutangValue = 6
    @taxinvoice = Taxinvoice.find(params[:taxinvoice_id])
    @taxinvoice.paiddate = Date.today.strftime('%d-%m-%Y')
    @taxinvoice_id = @taxinvoice.id

    @taxinvoice.downpayment_date = Date.today.strftime('%d-%m-%Y') if @taxinvoice.downpayment_date.nil?
  end

  def updatepayment
    inputs = params[:taxinvoice]

    @taxinvoice = Taxinvoice.find(inputs[:taxinvoice_id]) rescue nil
    @taxinvoice.paiddate = inputs[:paiddate]    

    createbankexpenserecord @taxinvoice.id, false if @taxinvoice.save

    redirect_to(taxinvoices_url, :notice => "Pelusanan Invoice untuk pelanggan<br /><strong class='yellow'>#{@taxinvoice.customer.name}</strong> sukses disimpan.".html_safe)
  end

  def downpayment
    inputs = params[:taxinvoice]

    @taxinvoice = Taxinvoice.find(inputs[:taxinvoice_id]) rescue nil

    old_amount = @taxinvoice.downpayment

    @taxinvoice.downpayment_date = inputs[:downpayment_date]
    @taxinvoice.downpayment = clean_currency(inputs[:downpayment])    
    
    bankexpensedownpayment @taxinvoice, old_amount if @taxinvoice.save

    redirect_to(request.referer, :notice => "Deposit Invoice untuk pelanggan<br /><strong class='yellow'>#{@taxinvoice.customer.name}</strong> sukses disimpan.".html_safe)
  end

  def canceldownpayment
    inputs = params[:taxinvoice]

    @taxinvoice = Taxinvoice.find(inputs[:taxinvoice_id]) rescue nil

    old_amount = @taxinvoice.downpayment

    @taxinvoice.downpayment_date = nil
    @taxinvoice.downpayment = '$0.00'
    
    bankexpensecanceldownpayment @taxinvoice, old_amount if @taxinvoice.save

    redirect_to(request.referer, :notice => "Down Payment untuk Pelanggan <br /><strong class='yellow'>#{@taxinvoice.customer.name}</strong> sukses dihapus.".html_safe)
  end  

  def destroy
    @taxinvoice = Taxinvoice.find(params[:id])
    @taxinvoice.taxinvoiceitems.each do |taxinvoiceitem|
      taxinvoiceitem.taxinvoice_id = nil
      taxinvoiceitem.save
    end
    @taxinvoice.deleted = true
    @taxinvoice.save

    destroybankexpenserecord @taxinvoice.id

    redirect_to(taxinvoices_url)
  end

  def cancelpayment
    @taxinvoice = Taxinvoice.find(params[:id])
    
    if !@taxinvoice.paiddate.nil?      
      Bankexpense.where("debitgroup_id IS NOT NULL AND creditgroup_id IS NOT NULL AND taxinvoice_id IN (#{@taxinvoice.id}) AND deleted IS FALSE").update_all(:deleted => true) rescue nil
      
      # kill old records
      Bankexpense.where("debitgroup_id = 96 AND taxinvoice_id IN (#{@taxinvoice.id}) AND deleted IS FALSE").update_all(:deleted => true) rescue nil

      @taxinvoice.downpayment_date = nil
      @taxinvoice.downpayment = '$0.00'

      @taxinvoice.paiddate = nil
      @taxinvoice.save
    end

    redirect_to(request.referer, :notice => "Pembayaran untuk Pelanggan <br /><strong class='yellow'>#{@taxinvoice.customer.name}</strong> sukses dibatalkan.".html_safe)
  end   

  def bankexpensedownpayment taxinvoice, old_amount
    inputBank = params[:bank_id]
    inputBank = 5 if inputBank.nil? 
    
    inputPiutang = params[:piutang_id]
    inputPiutang = 6 if inputPiutang.nil?

    bankexpense = Bankexpense.where(:taxinvoice_id => taxinvoice.id, :creditgroup_id => inputPiutang, :debitgroup_id => inputBank, :deleted => false).where("description LIKE 'Down Payment Invoice %'").first rescue nil
    bankexpense = Bankexpense.new if bankexpense.nil?
    
    bankexpense.debitgroup_id = inputBank
    bankexpense.creditgroup_id = inputPiutang
    bankexpense.taxinvoice_id = taxinvoice.id
    bankexpense.total = taxinvoice.downpayment
    bankexpense.description = "Down Payment Invoice " + taxinvoice.long_id + ", " + taxinvoice.customer.name
    bankexpense.date = taxinvoice.downpayment_date

    bank = Bankexpense.where(:taxinvoice_id => bankexpense.taxinvoice_id, :debitgroup_id => inputPiutang, :deleted => false).first rescue nil    
    if bank
      bankexpense.bankexpense_id = bank.id 
    end

    if bankexpense.save

      debit_to = Bankexpensegroup.find(bankexpense.debitgroup_id) rescue nil
      if !debit_to.nil?
        debit_to.total -= old_amount
        debit_to.total += bankexpense.total
        debit_to.save
      end

      credit_to = Bankexpensegroup.find(bankexpense.creditgroup_id) rescue nil
      if !credit_to.nil?
        credit_to.total += old_amount
        credit_to.total -= bankexpense.total
        credit_to.save
      end
    end
  end

  def bankexpensecanceldownpayment taxinvoice, old_amount

    bankexpense = Bankexpense.where(:taxinvoice_id => taxinvoice.id, :deleted => false).where("description LIKE 'Down Payment Invoice %'").first rescue nil

    if !bankexpense.nil?
      bankexpense.deleted = true

      if bankexpense.save
        debit_to = Bankexpensegroup.find(bankexpense.debitgroup_id) 
        if !debit_to.nil?
          debit_to.total -= old_amount
          debit_to.save
        end

        credit_to = Bankexpensegroup.find(bankexpense.creditgroup_id) 
        if !credit_to.nil?
          credit_to.total += old_amount
          credit_to.save
        end
      end
    end
  end 

  def createbankexpenserecord taxinvoice_id, create = true
     @taxinvoice = Taxinvoice.find(taxinvoice_id) rescue nil
     if @taxinvoice
        if create
          description = "Invoice " + @taxinvoice.long_id
          
          #record bank pendapatan 
          @bankexpensependapatan = Bankexpense.where(:taxinvoice_id => taxinvoice_id,  :creditgroup_id => ID_GROUP_PENDAPATAN, :deleted => false).first rescue nil
          needupdate = @bankexpensependapatan.nil? ? false : true
          @bankexpensependapatan = Bankexpense.new if @bankexpensependapatan.nil?
          @bankexpensependapatan.creditgroup_id = ID_GROUP_PENDAPATAN
          @bankexpensependapatan.taxinvoice_id = taxinvoice_id
          @bankexpensependapatan.description = description
          @bankexpensependapatan.date = @taxinvoice.date

          credit_to = Bankexpensegroup.find(ID_GROUP_PENDAPATAN) rescue nil          
          credit_to.total += @bankexpensependapatan.total if needupdate && !credit_to.nil?

          @bankexpensependapatan.total = @taxinvoice.total.to_f - @taxinvoice.gst_tax.to_f + @taxinvoice.price_tax.to_f + @taxinvoice.insurance_cost.to_f
          
          credit_to.total -= @bankexpensependapatan.total if !credit_to.nil?
          credit_to.save if @bankexpensependapatan.save

          #record bank ppn 
          if @taxinvoice.gst_tax.to_i > 0
            @bankexpenseppn = Bankexpense.where(:taxinvoice_id => taxinvoice_id,  :creditgroup_id => ID_GROUP_PPN, :deleted => false).first rescue nil
            needupdate = @bankexpenseppn.nil? ? false : true
            @bankexpenseppn = Bankexpense.new if @bankexpenseppn.nil?
            @bankexpenseppn.creditgroup_id = ID_GROUP_PPN
            @bankexpenseppn.taxinvoice_id = taxinvoice_id
            @bankexpenseppn.description = description
            @bankexpenseppn.date = @taxinvoice.date

            credit_to = Bankexpensegroup.find(ID_GROUP_PPN) rescue nil
            credit_to.total += @bankexpenseppn.total if needupdate && !credit_to.nil?

            @bankexpenseppn.total = @taxinvoice.gst_tax.to_i
            
            credit_to.total -= @bankexpenseppn.total if !credit_to.nil?
            credit_to.save if @bankexpenseppn.save
          end

          #record bank pph
          if  @taxinvoice.price_tax.to_i > 0
            @bankexpensepph = Bankexpense.where(:taxinvoice_id => taxinvoice_id,  :debitgroup_id => ID_GROUP_PPH, :deleted => false).first rescue nil
            needupdate = @bankexpensepph.nil? ? false : true
            @bankexpensepph = Bankexpense.new if @bankexpensepph.nil?
            @bankexpensepph.debitgroup_id = ID_GROUP_PPH
            @bankexpensepph.taxinvoice_id = taxinvoice_id
            @bankexpensepph.description = description
            @bankexpensepph.date = @taxinvoice.date

            debit_to = Bankexpensegroup.find(ID_GROUP_PPH) rescue nil
            debit_to.total -= @bankexpensepph.total if needupdate && !debit_to.nil?

            @bankexpensepph.total = @taxinvoice.price_tax.to_i
            
            debit_to.total += @bankexpensepph.total if !debit_to.nil?
            debit_to.save if @bankexpensepph.save
          end

          #record bank piutang
          @bankexpensepiutang = Bankexpense.where(:taxinvoice_id => taxinvoice_id,  :debitgroup_id => ID_GROUP_PIUTANG, :deleted => false).first
          needupdate = @bankexpensepiutang.nil? ? false : true
          @bankexpensepiutang = Bankexpense.new if @bankexpensepiutang.nil?
          @bankexpensepiutang.debitgroup_id = ID_GROUP_PIUTANG
          @bankexpensepiutang.taxinvoice_id = taxinvoice_id
          @bankexpensepiutang.description = description
          @bankexpensepiutang.date = @taxinvoice.date

          debit_to = Bankexpensegroup.find(ID_GROUP_PIUTANG) rescue nil
          debit_to.total -= @bankexpensepiutang.total if needupdate && !debit_to.nil?

          @bankexpensepiutang.total = @taxinvoice.total
          
          debit_to.total += @bankexpensepiutang.total if !debit_to.nil?
          debit_to.save if @bankexpensepiutang.save

        else
          #record bank pembayaran
          inputBank = params[:bank_id]
          inputBank = 5 if inputBank.nil? 
          
          inputPiutang = params[:piutang_id]
          inputPiutang = 6 if inputPiutang.nil?

          @bankexpensebayar = Bankexpense.where(:taxinvoice_id => taxinvoice_id, :creditgroup_id => inputPiutang, :debitgroup_id => inputBank, :deleted => false).where("description LIKE 'Pelunasan Invoice %'").first rescue nil
          @bankexpensebayar = Bankexpense.new if @bankexpensebayar.nil?

          @bankexpensebayar.debitgroup_id = inputBank
          @bankexpensebayar.creditgroup_id = inputPiutang
          @bankexpensebayar.taxinvoice_id = taxinvoice_id
          @bankexpensebayar.total = @taxinvoice.total - @taxinvoice.downpayment
          @bankexpensebayar.description = "Pelunasan Invoice " +  @taxinvoice.long_id + ", " + @taxinvoice.customer.name
          @bankexpensebayar.date = @taxinvoice.paiddate

          bank = Bankexpense.where(:taxinvoice_id => @bankexpensebayar.taxinvoice_id, :debitgroup_id => inputPiutang, :deleted => false).first rescue nil
          if bank
            @bankexpensebayar.bankexpense_id = bank.id
          end

          if @bankexpensebayar.save
            debit_to = Bankexpensegroup.find(@bankexpensebayar.debitgroup_id) 
            if !debit_to.nil?
              debit_to.total += @bankexpensebayar.total
              debit_to.save
            end

            credit_to = Bankexpensegroup.find(@bankexpensebayar.creditgroup_id) 
            if !credit_to.nil?
              credit_to.total -= @bankexpensebayar.total
              credit_to.save
            end
          end
        end
     end
  end

  def destroybankexpenserecord taxinvoice_id
    bankexpenses = Bankexpense.where(:taxinvoice_id => taxinvoice_id, :deleted => false)
    if bankexpenses.any?
      bankexpenses.each do |bankexpense|
        bankexpense.deleted = true
        bankexpense.deleteuser_id = current_user.id
        if bankexpense.save
          debit_to = Bankexpensegroup.find(bankexpense.debitgroup_id) rescue nil
          if !debit_to.nil?
              debit_to.total -= (bankexpense.total rescue 0)
              debit_to.save
          end

          credit_to = Bankexpensegroup.find(bankexpense.creditgroup_id) rescue nil
          if !credit_to.nil?
              credit_to.total += (bankexpense.total rescue 0)
              credit_to.save
          end
        end
      end
    end
  end

  def downloadexcel
    taxinvoice = Taxinvoice.find(params[:taxinvoice_id]) rescue nil
    filename = "invoices_" + Date.today.strftime('%d%m%Y') + ".xls"

    grandtotal = taxinvoice.total - taxinvoice.total.to_i 
    @is_pembulatan = ((grandtotal == 0))


    index_col = 1

    p = Axlsx::Package.new
    p.workbook.add_worksheet(:name => "Tagihan Invoice") do |sheet|

      bold = sheet.styles.add_style(:b => true)
      right = sheet.styles.add_style(:alignment => {:horizontal => :right})
      right_bold = sheet.styles.add_style(:alignment => {:horizontal => :right}, :b => true)
      
      sheet.add_row [''], :height => 20
      index_col +=1
      sheet.add_row ['','No. Invoice', taxinvoice.long_id], :height => 20, :widths => [:auto, :auto, :ignore]
      index_col +=1
      sheet.add_row ['','Tanggal', taxinvoice.date.strftime('%d-%m-%Y')], :height => 20, :widths => [:auto, :auto, :ignore]
      index_col +=1
      sheet.add_row ['','Periode', taxinvoice.period_start.strftime('%d-%m-%Y') + " - " + taxinvoice.period_start.strftime('%d-%m-%Y')], :height => 20, :widths => [:auto, :auto, :ignore]
      index_col +=1
      sheet.add_row ['','Nama', taxinvoice.customer.name], :height => 20, :widths => [:auto, :auto, :ignore]
      index_col +=1
      sheet.add_row ['','Alamat', taxinvoice.customer.address], :height => 20, :widths => [:auto, :auto, :ignore]
      index_col +=1

      #if !taxinvoice.customer.city.blank?
      #  sheet.add_row ['','', taxinvoice.customer.city], :height => 20, :widths => [:auto, :auto, :ignore]
      #  index_col +=1
      #end
      if !taxinvoice.customer.npwp.blank?
        sheet.add_row ['','NPWP', taxinvoice.customer.npwp], :height => 20, :widths => [:auto, :auto, :ignore]
        index_col +=1
      end 
      if !taxinvoice.product_name.blank?
        sheet.add_row ['','Barang', taxinvoice.product_name], :height => 20, :widths => [:auto, :auto, :ignore]
        index_col +=1
      end
      if !taxinvoice.spk_no.blank?
        sheet.add_row ['','SPK', taxinvoice.spk_no], :height => 20, :widths => [:auto, :auto, :ignore]
        index_col +=1
      end
      if !taxinvoice.po_no.blank?
        sheet.add_row ['','PO', taxinvoice.po_no], :height => 20, :widths => [:auto, :auto, :ignore]
        index_col +=1
      end
      if !taxinvoice.ship_name.blank?
        sheet.add_row ['','Nama Kapal', taxinvoice.ship_name], :height => 20, :widths => [:auto, :auto, :ignore]
        index_col +=1
      end
      if !taxinvoice.tank_name.blank?
        sheet.add_row ['','Jenis Tangki', taxinvoice.tank_name], :height => 20, :widths => [:auto, :auto, :ignore]
        index_col +=1
      end

      sheet.add_row [''], :height => 20
      sheet.add_row [''], :height => 20
      index_col +=2

      sheet.add_row ['','NO.', 'TGL KIRIM', 'NO POL', 'SURAT JALAN', 'QTY MUAT(KG)', 'QTY BONGKAR(KG)', 'TARIF', 'JURUSAN', 'TOTAL'], :height => 20, :style => [bold,bold,bold,bold,bold,right_bold,right_bold,right_bold,bold,right_bold]
      index_col +=1
      if taxinvoice.taxinvoiceitems.any?

        taxinvoice.taxinvoiceitems.order(:date, :sku_id).each_with_index do |taxinvoiceitem, i|
          if taxinvoiceitem.invoice.invoicetrain
            if taxinvoiceitem.invoice.invoices.first
              invoice_train = ", "+taxinvoiceitem.invoice.invoices.first.vehicle.current_id
              # invoice_train = "dshfhsdefhas"
            else
              invoice_train = ""
            end
          else
            invoice_train = ""
          end
          sheet.add_row ['',i+1, taxinvoiceitem.date.strftime('%d/%m/%Y'), taxinvoiceitem.invoice.vehicle.current_id + '' + invoice_train, taxinvoiceitem.sku_id, taxinvoiceitem.weight_gross, taxinvoiceitem.weight_net, to_currency_bank(taxinvoiceitem.price_per), taxinvoiceitem.invoice.route.name, to_currency_bank(taxinvoiceitem.total)], :height => 20, :style => [nil,nil,nil,nil,nil,nil,nil,nil,nil,right]
          index_col +=1
        end

      else
        taxinvoice.taxgenericitems.order(:date, :sku_id).each_with_index do |taxgenericitem, i|
          sheet.add_row ['',i+1, taxgenericitem.date.strftime('%d/%m/%Y'), taxgenericitem.vehicle.current_id, taxgenericitem.sku_id, taxgenericitem.weight_gross, taxgenericitem.weight_net, to_currency_bank(taxgenericitem.price_per), taxgenericitem.description, to_currency_bank(taxgenericitem.total)], :height => 20, :style => [nil,nil,nil,nil,nil,nil,nil,nil,nil,right]
          index_col +=1
        end

      end

      if taxinvoice.taxinvoiceitems.any?
        sheet.add_row ['','', 'SUBTOTAL', '','', taxinvoice.taxinvoiceitems.sum(:weight_gross), taxinvoice.taxinvoiceitems.sum(:weight_net), '', '', to_currency_bank(taxinvoice.taxinvoiceitems.sum(:total))], :height => 20, :style => [nil,nil,nil,nil,nil,nil,nil,nil,nil,right_bold]
        index_col +=1
      else
        sheet.add_row ['','', 'SUBTOTAL', '','', taxinvoice.taxgenericitems.sum(:weight_gross), taxinvoice.taxgenericitems.sum(:weight_net), '', '', to_currency_bank(taxinvoice.taxgenericitems.sum(:total))], :height => 20, :style => [nil,nil,nil,nil,nil,nil,nil,nil,nil,right_bold]
        index_col +=1
      end

      if taxinvoice.extra_cost > 0
        sheet.merge_cells 'C' + index_col.to_s + ':I'+ index_col.to_s
        sheet.add_row ['','',"Biaya Tambahan : " + taxinvoice.extra_cost_info, '','','','','','', to_currency_bank(taxinvoice.extra_cost)], :height => 20, :style => right_bold, :widths => [:ignore,:ignore,:ignore,:auto]
        index_col +=1
      end

      #PPN 10%
      sheet.merge_cells 'B' + index_col.to_s + ':I'+ index_col.to_s
      sheet.add_row ['',"PPN 10%",'','','','','','','', to_currency_bank(taxinvoice.gst_tax)], :height => 20, :style => right
      index_col +=1

      #PPh 
      sheet.merge_cells 'B' + index_col.to_s + ':I'+ index_col.to_s
      sheet.add_row ['',"PPh Pasal 23 2%",'','','','','','','', to_currency_bank(0 - taxinvoice.price_tax)], :height => 20, :style => right
      index_col +=1

      #total
      taxinvoice_total = @is_pembulatan ? to_currency(taxinvoice.total) : to_currency_bank(taxinvoice.total)
      sheet.merge_cells 'B' + index_col.to_s + ':H'+ index_col.to_s
      totalinwords =  "Terbilang:" + taxinvoice.total_in_words if !taxinvoice.total_in_words.blank?
      sheet.add_row ['', totalinwords,'','','','','','', 'TOTAL', taxinvoice_total], :height => 20, :widths => [:ignore,:ignore], :style => [nil,nil,nil,nil,nil,nil,nil,nil,right_bold,right_bold]
      index_col +=1

      sheet.add_row [''], :height => 20

      if !taxinvoice.description.blank?
        sheet.add_row ['',taxinvoice.description], :height => 20, :style => bold, :widths => [:auto, :ignore]
      end
 
    end
    p.use_autowidth = false
    p.use_shared_strings = true
    
    #if p.serialize("/tmp/#{filename}")
      #send_data("#{Rails.root}/tmp/#{filename}", :filename => filename, :type => :xls, :x_sendfile => true)
    #end

    send_data(p.to_stream.read, :filename => filename, :type => :xls, :x_sendfile => true)

  end
    
    def send_email

        # @name = 'Test'
        # @email = 'yudistira@mydevteam.com.au'
        # @finance_mail = 'finance@rdpitrans.com'
        
        # @taxinvoice = Taxinvoice.find(params[:taxinvoice_id])
        
        # if @taxinvoice.present? 
            
        # @long_id =  @taxinvoice.long_id
         
        # @total = to_currency(@taxinvoice.total)
        # @customer = @taxinvoice.customer.name
        # @sent_date = @taxinvoice.sentdate
        # inv_subject = "Invoice Tagihan "+@long_id+" "+@customer
            
        # if @sent_date.nil?
        #     @sent_date = Date.today.strftime('%d-%m-%Y')
        # end
            
        # html = render_to_string partial: 'email_template/taxinvoice_sent'
 
        # require 'uri'
        # require 'json'
        # require 'net/http'

        # url = URI('https://api.sendinblue.com/v3/smtp/email')

        # https = Net::HTTP.new(url.host, url.port)
        # https.use_ssl = true

        # request = Net::HTTP::Post.new(url)
        # request['accept'] = 'application/json'
        # request['content-type'] = 'application/json'
        # request['api-key'] = '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'
        # request.body = JSON.dump({
        #     'to': [
        #         {
        #         'email': @email,
        #         'name': @customer
        #         },
        #     ],
        #     'sender': {
        #         'email': 'no-reply@rdpitrans.com',
        #         'name': 'RDPI Trans'
        #     },
        #     'subject': inv_subject,
        #     'htmlContent': html,
        #     'headers': { 
        #         'charset': 'iso-8859-1'
        #     }
        # })

        # response = https.request(request)
            
        # render json: { status: 200, message: "Success", response: response }
            
        #end

    end

  def import_excel
    inputs = params[:taxinvoice]

    tmp = params[:file].tempfile
    file = File.join("public", params[:file].original_filename)
    FileUtils.cp tmp.path, file

    oo = Roo::Excelx.new(file)
    # oo = Roo::Spreadsheet.open(file)

    fetch_excel(oo, inputs[:taxinvoice_id])
    FileUtils.rm file

    # Taxinvoice.import_excel(params[:file], inputs[:taxinvoice_id])

    redirect_to request.referer, notice: "Invoice imported."
  end

  def fetch_excel(s, taxinvoice_id)
    s.default_sheet = s.sheets.first
     
     taxinvoice = Taxinvoice.find(taxinvoice_id)
     customer_id = taxinvoice.customer_id

     #add taxinvoiceitem
     5.upto(200) do |line|
      date = s.cell(line, 'C')
      nopol = s.cell(line,'D')
      route = s.cell(line,'E')
      weight_gross = s.cell(line, 'F')
      weight_net = s.cell(line, 'G')

      vehicle = Vehicle.where(:current_id => nopol).first rescue nil
      if vehicle.nil?
        vehicle_id = Vehicle.first.id
      else
        vehicle_id = vehicle.id
      end

      if !taxinvoice.nil?     
        if !date.nil?
          Taxgenericitem.create(:taxinvoice_id => taxinvoice.id , :customer_id => customer_id, :vehicle_id => vehicle_id, :date => date, :description => route, :weight_gross => weight_gross, :weight_net => weight_net )
        end
    end

     end
  end

  def update_tax

    @taxinvoice = Taxinvoice.find(params[:id])
    @taxinvoice.insurance_cost = params[:insurance_cost]
    @taxinvoice.claim_cost = params[:claim_cost]
    @taxinvoice.remarks = params[:remarks]
    subtotal = params[:subtotal].to_i
    subtotal = subtotal + @taxinvoice.extra_cost.to_i
    @taxinvoice.sentdate = (params[:sentdate] rescue nil)
    @taxinvoice.confirmeddate = (params[:confirmeddate] rescue nil)
    ppn = Setting.where(name: 'ppn')
    ppn = ppn.blank? ? 10 : ppn[0].value    
        
    ppn_percentage = params[:gst_tax].to_f
    if ppn_percentage > 0
      @taxinvoice.gst_tax = subtotal.to_f * (ppn_percentage.to_f / 100)
      @taxinvoice.gst_percentage = ppn_percentage.to_f
    else
      @taxinvoice.gst_tax = 0
      @taxinvoice.gst_percentage = 0
    end
      
    if params[:price_tax] == "Yes"
      @taxinvoice.price_tax = subtotal.to_f * 0.02 
    else
      @taxinvoice.price_tax = 0
    end

    grandtotal = subtotal.to_f + @taxinvoice.gst_tax.to_f - @taxinvoice.price_tax.to_f

    @taxinvoice.total = grandtotal - @taxinvoice.insurance_cost - @taxinvoice.claim_cost

    @taxinvoice.total_in_words = moneytowordsrupiah(@taxinvoice.total)

    if @taxinvoice.save
      render json: { status: 200, message: "Data Invoice untuk pelanggan<br /><strong class='yellow'>#{@taxinvoice.customer.name}</strong><br />sukses disimpan.".html_safe, invoice: params, taxinvoice: @taxinvoice.sentdate }
    else
      render json: { status: 400, message: "Data Invoice gagal diupdate" }, status: 400
    end
      
    # render json: @taxinvoice 
  end

  def clone

    @taxinvoice = Taxinvoice.find(params[:id])

    require "uri"
		require "net/http"
		require "openssl"
		require 'json'

    url = URI("https://office.puratrans.com/api_customers/get_all_customers")

		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Get.new(url.request_uri)

		response = http.request(request)
		@response = response.read_body
		
		if JSON(@response)['status'] == 404
			
		@customerlist = ''

		else	
			
		@customerlist = JSON(@response)['data']
			
		end

  end

  def transfer

    # @taxinvoice = Taxinvoice.find(params[:id])
    # customer_destinaton = params[:customer_id]
    # is_generic = @taxinvoice.generic

    # require "uri"
		# require "net/http"
		# require "openssl"
		# require 'json'

    # url = URI("https://office.puratrans.com/api_taxinvoices/create_taxinvoice")

		# http = Net::HTTP.new(url.host, url.port)
		# http.use_ssl = true
		# http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		# request = Net::HTTP::Post.new(url.request_uri)
    # request["Content-Type"] = "application/json"
    # request.body = JSON.dump({
    #   "taxinvoices": {
    #     "customer_id": customer_destinaton,
    #     "date": @taxinvoice.date,
    #     "long_id": @taxinvoice.long_id,
    #     "period_start": @taxinvoice.period_start,
    #     "period_end": @taxinvoice.period_end,
    #     "generic": true,
    #     "gst_tax": @taxinvoice.gst_tax,
    #     "gst_percentage": 0,
    #     "price_tax": @taxinvoice.price_tax,
    #     "description": 'Cloning dari Internal RDPI',
    #     "total": @taxinvoice.total,
    #     "user_id": 76,
    #   }
    # })

		# response = http.request(request)
		# @response = response.read_body
		
		# if JSON(@response)['status'] == 404
			
		# render json: { status: 400, message: "Customers not found" }, status: 400

		# else	
			
    #   @taxinvoice_id_destination = JSON(@response)['data']['id']

    #   if is_generic
    #     taxinvoiceitems = Taxgenericitem.where('taxinvoice_id = ?', @taxinvoice.id)
    #   else
    #     taxinvoiceitems = Taxinvoiceitem.where('taxinvoice_id = ?', @taxinvoice.id)
    #   end

    #   if taxinvoiceitems.present?
            
    #     taxinvoiceitems = taxinvoiceitems.map do |t|

    #       url = URI("https://office.puratrans.com/api_taxinvoices/create_taxinvoice_taxgenericitem")

    #       http = Net::HTTP.new(url.host, url.port)
    #       http.use_ssl = true
    #       http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    #       request = Net::HTTP::Post.new(url.request_uri)
    #       request["Content-Type"] = "application/json"

    #       if is_generic
    #         request.body = JSON.dump({
    #           "taxgenericitems": {
    #             "date": t.date,
    #             "load_date": t.date,
    #             "unload_date": t.date,
    #             "description": t.description,
    #             "sku_id": t.sku_id,
    #             "vehicle_id": t.vehicle.current_id,
    #             "taxinvoice_id": @taxinvoice_id_destination,
    #             "weight_gross": t.weight_gross,
    #             "weight_net": t.weight_net,
    #             "price_per": t.price_per,
    #             "total": t.total
    #           }
    #         })
    #       else
    #         request.body = JSON.dump({
    #           "taxgenericitems": {
    #             "date": t.date,
    #             "load_date": t.date,
    #             "unload_date": t.date,
    #             "description": t.invoice.route.name,
    #             "sku_id": t.sku_id,
    #             "vehicle_id": t.invoice.vehicle.current_id,
    #             "taxinvoice_id": @taxinvoice_id_destination,
    #             "weight_gross": t.weight_gross,
    #             "weight_net": t.weight_net,
    #             "price_per": t.price_per,
    #             "total": t.total
    #           }
    #         })
    #       end

    #       response = http.request(request)
    #     end

    #   end

    #   render json: {
    #     status: 200,
    #     data: JSON(@response)['data']['id'],
    #     message: 'Success Create Taxinvoice',
    #     }, status: 200

		# end
  end

end
