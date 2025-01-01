class TaxgenericinvoicesController < ApplicationController
	include ApplicationHelper
  include ActionView::Helpers::NumberHelper
	layout "application", :except => [:updateitems]
  protect_from_forgery :except => [:updateitems]
  before_filter :authenticate_user!, :set_section

  ID_GROUP_PPH = 11
  ID_GROUP_PPN = 10
  ID_GROUP_PIUTANG = 6
  ID_GROUP_PENDAPATAN = 22
  ID_GROUP_MANDIRI = 5
  ID_GROUP_DOWNPAYMENT = 96

  def set_section
    @section = "transactions2"
    @where = "taxgenericitems"
  end

  def generic_vehicles
    @vehicles = []
    Vehicle.active.order(:current_id).each do |vehicle|
      if vehicle.previous_id.present?
        @vehicles.push({ label: vehicle.current_id + ' (' + vehicle.previous_id + ')', value: vehicle.current_id })
      else
        @vehicles.push({ label: vehicle.current_id, value: vehicle.current_id })
      end
    end


    render :json => { :success => true, :layout => false,
        :vehicle => @vehicles
      }.to_json;
    # render :json => Vehicle.active.order(:current_id).pluck(:current_id)
  end

  def new
    @section = "taxinvoices"
    @where = "taxinvoices"
    @taxinvoice = Taxinvoice.find(params[:id]) rescue nil

    if @taxinvoice.nil?
      @customer = Customer.find(params[:customer_id]) rescue nil

      @taxinvoice = Taxinvoice.new
      @taxinvoice.date = Date.today.strftime('%d-%m-%Y')
      @taxinvoice.period_start = Date.today.strftime('%d-%m-%Y')
      @taxinvoice.period_end = Date.today.strftime('%d-%m-%Y')
      @taxinvoice.price_by = 'is_net'
      @needupdate = false
      @taxinvoice.sentdate = params[:sentdate]

      if @customer
        romenumber = getromenumber (Date.today.month.to_i)
        @long_id = Taxinvoice.where("to_char(date, 'MM-YYYY') = ?", Date.today.strftime('%m-%Y')).order("ID DESC").first.long_id[0,3].to_i + 1 rescue nil || '01'
        @long_id = ("%04d" % @long_id.to_s) + ' / TGH / PURA / ' + romenumber + ' / ' + Date.today.year.to_s

        @taxinvoice.long_id = @long_id
      end

      @process = "new"
    else
      @customer = @taxinvoice.customer
      @taxgenericitems = @taxinvoice.taxgenericitems.active.order(:date)
      @process = "edit"
    end

    @strPeriod = ""
    if !@taxinvoice.period_start.nil? and !@taxinvoice.period_end.nil?
      if @taxinvoice.period_start == @taxinvoice.period_end
        @strPeriod = @taxinvoice.period_start.strftime('%d-%m-%Y')
      else
        @strPeriod = @taxinvoice.period_start.strftime('%d-%m-%Y') + " s/d " + @taxinvoice.period_end.strftime('%d-%m-%Y')
      end
    end

    render 'generic'
  end

  def updateitems
    pembulatan = params["pembulatan"].present?
    # render json: {
    #   # cek: is_pembulatan
    # }
    # return false
    @customer = Customer.find(params[:customer_id]) rescue nil

    if !params[:customer_npwp].nil? and @customer.npwp != params[:customer_npwp]
      @customer.npwp = params[:customer_npwp]
      @customer.save
    end

    if params[:process] == "edit"
      @taxinvoice = Taxinvoice.find(params[:taxinvoice_id])
      @taxgenericitems = @taxinvoice.taxgenericitems.order(:date)
    else
      @taxinvoice = Taxinvoice.new
    end

    @taxinvoice.long_id = params[:long_id]
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
    @taxinvoice.waybill = params[:waybill]

    @taxinvoice.bank_id = params[:bank_id]

    @taxinvoice.extra_cost = params[:extra_cost].to_i
    @taxinvoice.extra_cost_info = params[:extra_cost_info]
    @taxinvoice.insurance_cost = params[:insurance_cost]
    @taxinvoice.claim_cost = params[:claim_cost]

    # @taxinvoice.total_in_words = params[:total_in_words]
    @taxinvoice.description = params[:description]
    @taxinvoice.price_by = params[:price_by]
    @taxinvoice.is_weightlost = params[:is_weightlost] == "Yes" ? true : false
    @taxinvoice.is_showqty_loaded = params[:is_showqty_loaded] == "Yes" ? true : false
    @taxinvoice.is_showqty_unloaded = params[:is_showqty_unloaded] == "Yes" ? true : false
    @taxinvoice.generic = true
    @taxinvoice.sentdate = params[:sentdate]
    @taxinvoice.user_id = current_user.id

    if @taxinvoice.save

      # ----- update values ----- #
      if params[:process] == "edit"
        taxgenericitems = @taxinvoice.taxgenericitems.active.order(:date)
        taxgenericitems.each do |item|
          if params["_vehicle_#{item.id}"] != ''
            vehicle = Vehicle.find_by_current_id(params["_vehicle_#{item.id}"]) rescue nil

            item.date = params["_date_#{item.id}"]
            item.vehicle_id = vehicle.id unless vehicle.nil?
            item.sku_id = params["_sku_#{item.id}"]
            item.description = params["_route_#{item.id}"]
            item.weight_gross = params["_gross_#{item.id}"].to_i rescue 0
            item.weight_net = params["_net_#{item.id}"].to_i rescue 0
            item.price_per = params["_price_#{item.id}"].gsub(",",".").to_f rescue 0

            puts params["_date_#{item.id}"]

            item.total = item.price_per

            if item.price_per < 300000
              item.total *= @taxinvoice.price_by == 'is_gross' ? item.weight_gross : item.weight_net
            end
          else
            item.deleted = true
          end

          item.save
        end
      end

        #----- new values if total generic item <= 10 ----- #

      if @taxinvoice.taxgenericitems.count <= 20
        _dates, _vehicles, _skus, _routes = params[:_date], params[:_vehicle], params[:_sku], params[:_route]
        _gross, _net, _price = params[:_gross], params[:_net], params[:_price], params[:_total]

        _dates.each_with_index do |date, i|
          if date.present? and _vehicles[i].present? and _routes[i].present?
            vehicle = Vehicle.find_by_current_id(_vehicles[i]) rescue nil

            if vehicle
              @taxgenericitem = Taxgenericitem.new
              @taxgenericitem.taxinvoice_id = @taxinvoice.id
              @taxgenericitem.customer_id = @taxinvoice.customer_id
              @taxgenericitem.date = date
              @taxgenericitem.vehicle_id = vehicle.id
              @taxgenericitem.sku_id = _skus[i]
              @taxgenericitem.description = _routes[i]
              @taxgenericitem.weight_gross = _gross[i].to_i rescue 0
              @taxgenericitem.weight_net = _net[i].to_i rescue 0
              @taxgenericitem.price_per = _price[i].gsub(",",".").to_f rescue 0

              @taxgenericitem.total = @taxgenericitem.price_per

              if @taxgenericitem.price_per < 300000
                @taxgenericitem.total *= @taxinvoice.price_by == 'is_gross' ? @taxgenericitem.weight_gross : @taxgenericitem.weight_net
              end
              @taxgenericitem.save
            end
          end
        end

      end

      @taxinvoice.period_start = @taxinvoice.taxgenericitems.active.minimum("date")
      @taxinvoice.period_end = @taxinvoice.taxgenericitems.active.maximum("date")

      subtotal = @taxinvoice.taxgenericitems.active.sum(:total) + @taxinvoice.extra_cost.to_f

      #ppn_new
      ppn = Setting.where(name: 'ppn')
      ppn = ppn.blank? ? 12 : ppn[0].value

      # @taxinvoice.gst_tax = params[:gst_tax] == "Yes" ? subtotal.to_f * (ppn.to_f / 100) : 0
      @taxinvoice.price_tax = params[:price_tax] == "Yes" ? subtotal.to_f * 0.02 : 0
      ppn_percentage = params[:gst_tax].to_f
      if ppn_percentage > 0
        @taxinvoice.gst_tax = subtotal.to_f * (ppn_percentage.to_f / 100)
      else
        @taxinvoice.gst_tax = 0
      end
      @taxinvoice.gst_percentage = ppn_percentage
      if pembulatan
        @taxinvoice.total = subtotal.round + @taxinvoice.gst_tax.round - @taxinvoice.price_tax.round - @taxinvoice.insurance_cost.round - @taxinvoice.claim_cost.round
      else
        @taxinvoice.total = subtotal.to_f + @taxinvoice.gst_tax.to_f - @taxinvoice.price_tax.to_f - @taxinvoice.insurance_cost.to_f - @taxinvoice.claim_cost.to_f
      end

      @taxinvoice.total_in_words = moneytowordsrupiah(@taxinvoice.total)

      @taxinvoice.save
    end

    createbankexpenserecord @taxinvoice.id, true

    redirect_to("/taxinvoices/generic/#{@taxinvoice.id}")
  end

  def create
  end

  def update
  end

  def destroy
  end

  def createbankexpenserecord taxinvoice_id, create=false
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

          @bankexpensependapatan.total = @taxinvoice.total.to_f - @taxinvoice.gst_tax.to_f + @taxinvoice.price_tax.to_f

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
          @bankexpensebayar = Bankexpense.where(:taxinvoice_id => taxinvoice_id, :creditgroup_id => ID_GROUP_PIUTANG ,:debitgroup_id => ID_GROUP_MANDIRI, :deleted => false).first
          @bankexpensebayar = Bankexpense.new if @bankexpensebayar.nil?
          @bankexpensebayar.debitgroup_id = ID_GROUP_MANDIRI
          @bankexpensebayar.creditgroup_id = ID_GROUP_PIUTANG
          @bankexpensebayar.taxinvoice_id = taxinvoice_id
          @bankexpensebayar.total = @taxinvoice.total - @taxinvoice.downpayment
          @bankexpensebayar.description = "Pelunasan Invoice " +  @taxinvoice.long_id[0,4] + ", " + @taxinvoice.customer.name
          @bankexpensebayar.date = @taxinvoice.paiddate

          bank = Bankexpense.where(:taxinvoice_id => @bankexpensebayar.taxinvoice_id, :debitgroup_id => ID_GROUP_PIUTANG, :deleted => false).first rescue nil
          if bank
            @bankexpensebayar.bankexpense_id = bank.id
          end

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
  end
end
