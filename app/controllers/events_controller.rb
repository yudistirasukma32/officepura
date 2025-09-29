class EventsController < ApplicationController
  require "uri"
  require "net/http"
  require "openssl"
  require 'json'
	include ApplicationHelper
  include ActionView::Helpers::NumberHelper
	layout "application", :except => [:getevents, :getestimatedtonage, :resync, :get_unpaid_inv, :remove]
  before_filter :authenticate_user!, :set_section

  def set_section
   	@section = "events"
    query = params[:type] ? "-cancelled" : ""
    @where = "events" + query
    @estimated_tonage = [20000, 25000, 30000, 35000, 40000]
    @estimated_tonage_lt = [24000, 26000, 28000, 30000, 32000]
    @estimated_tonage_kg = [20000, 25000, 30000, 35000, 40000]
    @estimated_tonage_m3 = [45, 47]
    @price_per_types = ["KG", "LITER", "M3", "BORONGAN"]
    @tanktype = ['ISOTANK', 'LOSBAK', 'DROPSIDE', 'TANGKI BESI', 'TANGKI STAINLESS', 'KONTAINER STANDART', 'KONTAINER OPENSIDE', 'TRUK BOX', 'MULTIFUNGSI']
    @provinces = [
      "Aceh",
      "Sumatera Utara",
      "Sumatera Barat",
      "Jambi",
      "Bengkulu",
      "Sumatera Selatan",
      "Lampung",
      "Banten",
      "DKI Jakarta",
      "Jawa Barat",
      "Jawa Tengah",
      "DIY (Yogyakarta)",
      "Jawa Timur",
      "Bali",
      "NTB",
      "NTT",
      "Riau"
    ]
  end

  def getestimatedtonage
    if params[:price_per_type] == 'M3'
      @estimated_tonage = @estimated_tonage_m3
      render :json => { :success => true, :html => render_to_string(:partial => "events/estimatedtonage", :layout => false) }.to_json;
    elsif params[:price_per_type] == 'KG'
      @estimated_tonage = @estimated_tonage_kg
      render :json => { :success => true, :html => render_to_string(:partial => "events/estimatedtonage", :layout => false) }.to_json;
    elsif params[:price_per_type] == 'LITER'
      @estimated_tonage = @estimated_tonage_lt
      render :json => { :success => true, :html => render_to_string(:partial => "events/estimatedtonage", :layout => false) }.to_json;
    end

  end

  def index
  end

  def version2
    @where = "version-2"
    respond_to :html
  end

  def new
    @process = 'new'
    @event = Event.new
    @event.start_date = Date.today.strftime('%d-%m-%Y')
    @event.end_date = Date.today.strftime('%d-%m-%Y')
    @isdelete = false
    
    @customer = @event.customer
    @taxinvoice = Taxinvoice.active.where("paiddate is null and customer_id = ?", @event.customer_id)
    @taxinvoice_total = @taxinvoice.sum(:total)

  end

  def edit
    @process = 'edit'
    @event = Event.find(params[:id])
    @event.start_date = @event.start_date.strftime('%d-%m-%Y') if !@event.start_date.blank?
    @event.end_date = @event.end_date.strftime('%d-%m-%Y') if !@event.end_date.blank?
    @isdelete = true
    
    @customer = @event.customer
    @taxinvoice = Taxinvoice.active.where("paiddate is null and customer_id = ?", @event.customer_id)
    @taxinvoice_total = @taxinvoice.sum(:total)

    @eventmemos = Eventmemo.active.where('event_id = ?', @event.id)
    @eventcleaningmemos = Eventcleaningmemo.active.where('event_id = ?', @event.id)

    @taxinvoiceitemvs = Taxinvoiceitemv.active.where(event_id: params[:id]).where("total > money(0)")
    @invoices = Invoice.active.where('event_id = ?', @event.id)

    if @invoices.present?
        inv = @invoices.select('id').pluck('id')
        @taxinvoiceitems = Taxinvoiceitem.active.where('invoice_id IN (?)', inv)
        @invoicereturns = Invoicereturn.active.where('invoice_id IN (?)', inv)
        puts '====='
        puts @invoicereturns
    end
  end

  def create
    # eventvendors = []
    # if params[:vendor_name].present? && params[:event][:need_vendor].to_i == 1
    #   params[:vendor_name].each_with_index do |vendor,i|
    #     eventvendors.push({
    #       name: vendor,
    #       vehicle_current_id: params[:vehicle_current_id][i],
    #       iso_cont_number: params[:iso_cont_number][i],
    #       quantity: params[:quantity][i],
    #     })

    #   end
    # end

    # render json: eventvendors
    # return false
    inputs = params[:event]

    if inputs[:invoicetrain] == false || inputs[:invoicetrain] == "false"

      inputs[:operator_id] = 0
      inputs[:routetrain_id] = 0
      inputs[:station_id] = 0

    end

    if inputs[:invoicetrain] == false && inputs[:losing] == true

      inputs[:invoicetrain] = false
      inputs[:losing] = true
      inputs[:invoiceship] = false

    end

    if inputs[:invoicetrain] == false && inputs[:losing] == false

      inputs[:invoicetrain] = false
      inputs[:losing] = false
      inputs[:invoiceship] = false

    end

    if inputs[:invoicetrain] == 'roro'

      inputs[:invoicetrain] = false
      inputs[:invoiceship] = true

    end

    @event = Event.new(inputs)

    query = @event.cancelled ? "?type=cancelled" : ""
    @event.user_id = current_user.id

    if @event.save

      if params[:so_number].present?
        eventso = params[:so_number].map do |so_number|
          {
            customer_id: params[:event][:customer_id],
            long_id: so_number
          }
        end

        @event.eventsalesorders.create(eventso)
      end

      if params[:vendor_name].present? && params[:event][:need_vendor].to_i == 1
        eventvendors = []
        params[:vendor_name].each_with_index do |vendor,i|
          eventvendors.push({
            name: vendor,
            vehicle_current_id: params[:vehicle_current_id][i],
            iso_cont_number: params[:iso_cont_number][i],
            quantity: params[:quantity][i],
          })

        end
        @event.eventvendors.create(eventvendors)
      end
#      redirect_to(events_path + query, :notice => 'Data Event telah ditambah')

      # update province
      update_route_province @event.route_id, @event.load_province, @event.unload_province

      redirect_to(edit_event_url(@event), :notice => 'Data Event / DO berhasil ditambah.')

    else
      render :action => 'new'

    end
  end

  def update

    # render json: params
    # return false
    @event = Event.find(params[:id])
    inputs = params[:event]

    if inputs[:need_vendor] == '0'
        inputs[:vendor_name] = ''
    end

    if inputs[:invoicetrain] == false || inputs[:invoicetrain] == "false"

      inputs[:operator_id] = 0
      inputs[:routetrain_id] = 0
      inputs[:station_id] = 0
      inputs[:invoiceship] = false

    end

    if inputs[:invoicetrain] == 'roro'

      inputs[:invoicetrain] = false
      inputs[:invoiceship] = true

    end

    if @event.update_attributes(inputs)
      # if params[:so_number].present?
      #   Eventsaleorder.where(event_id: @event.id).delete_all
      #     soitems = params[:so_number].map do |so|
      #       {
      #         long_id: so
      #       }
      #     end
      #     @event.eventsalesorders.create(soitems)
      # end
      if params[:event][:need_vendor].to_i == 1
        Eventvendor.where(event_id: params[:id]).delete_all
        if params[:vendor_name].present?
          eventvendors = []
          params[:vendor_name].each_with_index do |vendor,i|
            if vendor.present?
              eventvendors.push({
                name: vendor,
                vehicle_current_id: params[:vehicle_current_id][i],
                iso_cont_number: params[:iso_cont_number][i],
                quantity: params[:quantity][i],
              })
            end

          end
          @event.eventvendors.create(eventvendors)
        end

      end
      query = @event.cancelled ? "?type=cancelled" : ""

      # if @event.invoicetrain
      #   @event.office_id = nil
      # else
      #   @event.station_id = nil
      # end
      @event.save

      if @event.cancelled
        add_eventlog @event.id, 'DO dibatalkan'
      else
        add_eventlog @event.id, 'DO diedit'
      end

      Eventsalesorder.where(event_id: @event.id).delete_all
      if params[:so_number].present?
        eventso = params[:so_number].map do |so_number|
          {
            customer_id: params[:event][:customer_id],
            long_id: so_number
          }
        end

        @event.eventsalesorders.create(eventso)
      end

#      redirect_to(events_path + query, :notice => 'Data Event telah disimpan')

      redirect_to(edit_event_url(@event), :notice => 'Data Event / DO berhasil di-edit.')

    else
      render :action => 'edit'
    end

  end

  def destroy
    @event = Event.find(params[:id])
    @event.deleted = true
    @event.deleteuser_id = current_user.id
    @event.save

    add_eventlog @event.id, 'DO dihapus'
    
    redirect_to(events_path)
  end

  def remove
    @event = Event.find(params[:id])
  
    unless @event
      redirect_to events_path, alert: 'Event tidak ditemukan'
      return
    end
  
    @event.deleted = true
    @event.deleteuser_id = current_user.id
    @event.reject_reason = params[:reject_reason]
  
    if @event.save
      add_eventlog @event.id, 'DO dihapus'
    end

    render :json => { :success => true }
    
  end

  def get_event_by_customer

    customer_id = params[:customer_id]
    @is_train = params[:train]

    @intervalago = Setting.find_by_name("DO Days Interval Ago").value rescue nil || 20
    @intervalnext = Setting.find_by_name("DO Days Interval Next").value rescue nil || 5

    if customer_id == "50" || customer_id == "51" || customer_id == "144"

      @events = Event.active.where("end_date BETWEEN current_date - interval ? day AND current_date + interval ? day", @intervalago, @intervalnext).order(:start_date)

      if current_user.office_id.present? && !current_user.owner
        @events = @events.where("office_id = ?", current_user.office_id)
      end

      render :json => { :success => true, :html => render_to_string(:partial => "invoices/events", :layout => false) }.to_json;

    else

        if @is_train == "0"

          @events = Event.active.where("customer_id = ? AND end_date BETWEEN current_date - interval ? day AND current_date + interval ? day AND invoicetrain = false", params[:customer_id], @intervalago, @intervalnext).order(:start_date)

          if current_user.office_id.present? && !current_user.owner
            @events = @events.where("office_id = ?", current_user.office_id)
          end

          render :json => { :success => true, :html => render_to_string(:partial => "invoices/events", :layout => false) }.to_json;

        else

          @events = Event.active.where("customer_id = ? AND end_date BETWEEN current_date - interval ? day AND current_date + interval ? day AND invoicetrain = true", params[:customer_id], @intervalago, @intervalnext).order(:start_date)

          if current_user.office_id.present? && !current_user.owner
            @events = @events.where("office_id = ?", current_user.office_id)
          end

          render :json => { :success => true, :html => render_to_string(:partial => "invoices/events", :layout => false) }.to_json;

        end

    end

  end

  def getevents

    if params[:type] == 'bookings'

      @bookings = Booking.active.where("date >= ?", 2.months.ago).order(:date)

      @events = @bookings.map do |e|

        createdUser = ''
        if e.user.username
          createdUser = ' ('+e.user.username+')'
        end

        summary = 'Booking ' + e.vehicle.current_id  + ' u/ DO #' + e.event_id.to_s + ' | ' +  e.event.summary +  createdUser

        {
          :id => e.id,
          :summary => summary,
          :start_date => e.date,
          :end_date => e.date,
          :is_booking => true
        }
      end

    elsif params[:type] == 'cancelled'

      @events = Event.where("deleted = false AND cancelled = true and start_date >= ?", 3.months.ago).order(:id)

      @events = @events.map do |e|

        if e.company.nil?
          company = ' [RDPI]'
          summary = e.summary + company + ' / ' + e.user.username rescue nil
        else
          company = e.company.abbr
          summary = e.summary + ' ['+company+']' + ' / ' + e.user.username rescue nil
        end

        {
            :id => e.id,
            :authorised => e.authorised,
            :summary => summary,
            :cancelled => e.cancelled,
            :start_date => e.start_date,
            :end_date => e.end_date,
            :customer_id => e.customer_id

        }
        end
    else
      @events = Event.active.where("start_date >= ?", 3.months.ago).order(:id)

      if current_user.office_id.present? && !current_user.owner
        @events = @events.where("office_id = ?", current_user.office_id)
      end

      invoices = Invoice.active.select('event_id').where("date >= ?", 3.months.ago).pluck(:event_id)

      @events = @events.map do |e|
        vendor = Taxinvoiceitemv.active.select('event_id, total').where("event_id IN (?) AND taxinvoiceitemvs.total > '0'", e.id)

        handled = false
        half_completed = false
        completed = false
        invoiced = false
        train = false
        completed_by_vendor = false

        is_stapel = false
        is_insurance = false

        bkk = ''
        taxinvoice = ''
        event_qty = 1

        if e.qty
            event_qty = e.qty
        end

        # if e.is_stapel
        #   is_stapel = true
        # end

        if e.is_insurance
          is_insurance = true
        end

        if e.need_vendor && vendor.count > 0
          if vendor.count >= event_qty / 2
            invoiced = true
          end
        elsif e.need_vendor
          completed_by_vendor = true
        end

        if invoices.index(e.id)

          bkk_unconfirmed = Invoice.active.select('event_id').where('event_id = ?', e.id).where('id not in (select invoice_id from invoicereturns where deleted = false)').pluck(:id)
          bkk = Invoice.active.select('event_id').where('event_id = ?', e.id).where('id not in (select invoice_id from invoicereturns where deleted = false)').where('id in (select invoice_id from receipts where deleted = false)').pluck(:id)

          if bkk_unconfirmed.count > 0 && bkk.count == 0
            handled = true
          end

          # bkk = Invoice.active.select('event_id').where('event_id = ?', e.id).where().pluck(:id)

          if bkk.count > 0 || vendor.count > 0
            this_bkk = Invoice.active.select('id, invoicetrain, quantity').find(bkk[0])

            #Check BKK train/not
            if this_bkk.invoicetrain

              train = true

              #Check QTY of BKK match / not with QTY on event
              if bkk.count >= event_qty.to_i*2

                completed = true

                taxinvoices = Taxinvoiceitem.active.select('invoice_id, total').where("taxinvoiceitems.invoice_id IN (?) AND taxinvoiceitems.total > '0'", bkk).pluck(:id)

                if taxinvoices.count + vendor.count >= bkk.count / 2

                  invoiced = true

                end

              else

                half_completed = true
                completed = false

                if e.need_vendor && vendor.count > 0
                  if vendor.count >= event_qty / 2
                    invoiced = true
                  end
                elsif e.need_vendor
                  completed_by_vendor = true
                end
              end

            else

              train = false
              half_completed = true

              #Check QTY of BKK match / not with QTY on event
              if bkk.count >= event_qty.to_i

                completed = true

                taxinvoices = Taxinvoiceitem.active.select('invoice_id, total').where("taxinvoiceitems.invoice_id IN (?) AND taxinvoiceitems.total > '0'", bkk).pluck(:id)

                if taxinvoices.count + vendor.count >= bkk.count

                  invoiced = true

                end
              end
            end

          else
            completed = false
          end

        end

        if e.company.nil?
          company = ' [RDPI]'
          summary = e.summary + company + ' / ' + e.user.username rescue nil
        else

          if e.office.nil?
            company = e.company.abbr
            summary = e.summary + ' ['+company+']' + ' / ' + e.user.username rescue nil
          else
            company = e.company.abbr
            summary = e.summary + ' ['+company+'] / ' + e.office.abbr + ' / ' + e.user.username rescue nil
          end

        end

        {
          :id => e.id,
          :handled => handled,
          :authorised => e.authorised,
          :summary => summary,
          :cancelled => e.cancelled,
          :start_date => e.start_date,
          :end_date => e.end_date,
          :customer_id => e.customer_id,
          :downpayment_amount => e.downpayment_amount.to_i,
          :bkk => bkk,
          :invoicetrain => train,
          :half_completed => half_completed,
          :completed => completed,
          :completed_by_vendor => completed_by_vendor,
          :invoiced => invoiced,
          :sj => taxinvoices,
          :is_stapel => is_stapel,
          :is_insurance => is_insurance
        }

      end
    end

    respond_to do |format|
       format.json { render :json => @events }
     end
  end

  def geteventsv2

    @events = Event.active.where("start_date >= ?", 2.months.ago).order(:id)

    # @events = Event.active.where("id = 44746 or id = 44747")
    user_office_id = current_user.office_id
    if !cek_roles 'Admin Keuangan'
      if user_office_id.present? && !current_user.owner
        @events = @events.where("office_id = ?", user_office_id)
      end
    end

    @events = @events.map do |e|

      # init status
      train = false
      completed_by_vendor = false
      is_stapel = false
      is_insurance = false
      addclass = nil
      darat = false

      handled = false
      half_completed = false
      completed = false
      invoiced = false
      taxinvoiced = false

      event_qty = e.qty rescue 1

      # vendor
      vendor = Taxinvoiceitemv.active.select('event_id, total').where("event_id IN (?) AND taxinvoiceitemvs.total > '0'", e.id)

      if e.need_vendor && vendor.count > 0
        if vendor.count >= event_qty / 2
          invoiced = true
        end
      elsif e.need_vendor
        completed_by_vendor = true
      end

      # if e.is_stapel
      #   is_stapel = true
      # end

      if e.is_insurance
        is_insurance = true
      end

      # bkk
      bkk_unconfirmed = e.invoice_count
      bkk_confirmed = e.invoiceconfirmed_count
      invoice_taxitems_count = e.invoice_taxitems_count
      invoice_taxinv_count = e.invoice_taxinv_count

      if bkk_unconfirmed.to_i > 0
        handled = true
      end

      if bkk_confirmed.to_i > 0 || vendor.count > 0

        invoicetrain = e.invoicetrain

        if invoicetrain
          train = true
          addclass = 'is_invoicetrain'
          if bkk_confirmed.to_i >= event_qty.to_i*2
            completed = true
          else
            half_completed = true
          end

          if invoice_taxitems_count.to_i > 0 && invoice_taxitems_count.to_i >= bkk_confirmed.to_i/2
            invoiced = true
          end

          if invoice_taxinv_count.to_i > 0 && invoice_taxinv_count.to_i == invoice_taxitems_count.to_i
            taxinvoiced = true
          end

        else

          if bkk_confirmed.to_i >= event_qty.to_i
            completed = true
          else
            half_completed = true
          end

          if invoice_taxitems_count.to_i > 0 && invoice_taxitems_count.to_i == bkk_confirmed.to_i
            invoiced = true
          end

          if invoice_taxinv_count.to_i > 0 && invoice_taxinv_count.to_i == invoice_taxitems_count.to_i
            taxinvoiced = true
          end

        end

      end

      if e.company.nil?
        company = ' [RDPI]'
        summary = e.summary + company + ' / ' + e.user.username rescue nil
      else

        if e.office.nil?
          company = e.company.abbr
          summary = e.summary + ' ['+company+']' + ' / ' + e.user.username rescue nil
        else
          company = e.company.abbr
          summary = e.summary + ' ['+company+'] / ' + e.office.abbr + ' / ' + e.user.username rescue nil
        end

      end

      if !e.invoicetrain
        summary = summary + ' (*Darat)'
        darat = true
      end

      {
        :id => e.id,
        :handled => handled,
        :authorised => e.authorised,
        :summary => summary,
        :cancelled => e.cancelled,
        :start_date => e.start_date,
        :end_date => e.end_date,
        :customer_id => e.customer_id,
        :downpayment_amount => e.downpayment_amount.to_i,
        :invoicetrain => train,
        :darat => darat,
        :addclass => addclass,
        :half_completed => half_completed,
        :completed => completed,
        :completed_by_vendor => completed_by_vendor,
        :is_stapel => is_stapel,
        :is_insurance => is_insurance,
        :vendor => vendor.count,
        :invoiced => invoiced,
        :taxinvoiced => taxinvoiced,
        :bkk => bkk_unconfirmed,
        :bkk_confirmed => bkk_confirmed,
        :sj => invoice_taxitems_count,
        :tagihan => invoice_taxinv_count
      }

    end

    # respond_to do |format|
    #   format.json { render :json => @events }
    # end

    render :json => @events

  end

  def resync
    @events = Event.active.where("start_date >= ?", 2.month.ago).order(:id)

    # @events = Event.active.where("id = 44746 or id = 44747")
    user_office_id = current_user.office_id
    if !cek_roles 'Admin Keuangan'
      if user_office_id.present? && !current_user.owner
        @events = @events.where("office_id = ?", user_office_id)
      end
    end

    @events = @events.map do |e|
      updateinvoice_count e.id
      updateinvoiceconfirmed_count e.id
      updateinvoice_taxitems_count e.id
    end

    render :json => { :success => true }

  end

  def report_events

    @where = 'report-events'
    @startdate = params[:startdate] || Date.today.strftime('%d-%m-%Y')
    @enddate = params[:enddate] || Date.today.strftime('%d-%m-%Y')

    @customer = Customer.find(params[:customer_id]) rescue nil
    @customer_id = @customer.id if @customer

    @status = params[:status]

    @id = params[:id]

    if @customer.present?
      @events = @customer.events.active
    else
      @events = Event.active
    end

    @events = @events.where("start_date BETWEEN :startdate AND :enddate", {:startdate => @startdate.to_date, :enddate => @enddate.to_date})

    if @id.present?

      @events = Event.where('id = ?', @id)

    end

    @events = @events.order(:start_date)

    @invoices = Invoice.active.select('event_id').where("date >= ?", 12.months.ago).pluck(:event_id)

    render "report-events"
  end

  def report_dpevents

    @where = 'report-dp-events'
    @startdate = params[:startdate] || Date.today.strftime('%d-%m-%Y')
    @enddate = params[:enddate] || Date.today.strftime('%d-%m-%Y')

    @customer = Customer.find(params[:customer_id]) rescue nil
    @customer_id = @customer.id if @customer

    @id = params[:id]

    if @customer.present?
      @events = @customer.events.active
    else
      @events = Event.active
    end

    @events = @events.where("start_date BETWEEN :startdate AND :enddate", {:startdate => @startdate.to_date, :enddate => @enddate.to_date})

    if @id.present?

      @events = Event.where('id = ?', @id)

    end

    @events = @events.where("downpayment_amount > money(0)")
    @events = @events.order(:start_date)

    @invoices = Invoice.active.select('event_id').where("date >= ?", 3.months.ago).pluck(:event_id)

    render "report-dpevents"

  end

  def event_summary

    @where = 'report-events-summary'
    @startdate = params[:startdate] || Date.today.strftime('%d-%m-%Y')
    @enddate = params[:enddate] || Date.today.strftime('%d-%m-%Y')

    # @customer = Customer.find(params[:customer_id]) rescue nil
    # @customer_id = @customer.id if @customer

    @events = Event.active.where("start_date BETWEEN :startdate AND :enddate", {:startdate => @startdate.to_date, :enddate => @enddate.to_date})

    @customer_id = params[:customer_id]

    if @customer_id.present?
      @customer = Customer.find(params[:customer_id]) rescue nil
      @events = @events.where('customer_id = ?', @customer_id)
    end

    @offices = Office.active.where("id in (?)", @events.pluck('office_id')).order(:name)
    @office_id = params[:office_id]

    if @office_id.present? and @office_id != "all"
      @office = Office.find(params[:office_id]) rescue nil
      @events = @events.where('office_id = ?', @office_id)
    end

    @id = params[:id]
    if @id.present?
      @events = Event.where('id = ?', @id)
    end

    @events = @events.order(:start_date)
    @customers = Customer.active.where("id in (?)", @events.pluck('customer_id')).order(:name)

    render "report-events-summary"
  end

  def cancelled

    @where = 'events-cancelled'
    @startdate = params[:startdate] || Date.today.strftime('%d-%m-%Y')
    @enddate = params[:enddate] || Date.today.strftime('%d-%m-%Y')

    # @customer = Customer.find(params[:customer_id]) rescue nil
    # @customer_id = @customer.id if @customer

    @events = Event.where("(deleted = true OR cancelled = true) AND start_date BETWEEN :startdate AND :enddate", {:startdate => @startdate.to_date, :enddate => @enddate.to_date})
    @customer_id = params[:customer_id]

    if @customer_id.present?
      @customer = Customer.find(params[:customer_id]) rescue nil
      @events = @events.where('customer_id = ?', @customer_id)
    end

    @offices = Office.active.where("id in (?)", @events.pluck('office_id')).order(:name)
    @office_id = params[:office_id]

    if @office_id.present? and @office_id != "all"
      @office = Office.find(params[:office_id]) rescue nil
      @events = @events.where('office_id = ?', @office_id)
    end

    @id = params[:id]
    if @id.present?
      @events = Event.where('id = ?', @id)
    end

    @events = @events.order(:start_date)
    @customers = Customer.active.where("id in (?)", @events.pluck('customer_id')).order(:name)

    render "cancelled"
  end

  def getdodetail
    @event = Event.find(params[:event_id])
    render json: { operator_id: @event.operator_id, office_id: @event.office_id, cargo_type: @event.cargo_type, tanktype: @event.tanktype, route_id: @event.route_id, routetrain_id: @event.routetrain_id, is_insurance: @event.is_insurance}, status: 200
  end

  def add_dovendor
    @section = "ops"
    @where = "adddovendor"
    @event = Event.find(params[:event_id])

    if @event.load_date.nil?
      @event.load_date = Date.today
    end

  end

  def indexadddovendor
    @section = "ops"
    @where = "adddovendor"
    @date = params[:date]
    @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
    @events = Event.where("created_at::DATE = ? AND deleted=FALSE AND need_vendor=FALSE", @date.to_date)
    if params[:event_id].present?
      @events = Event.where(id: params[:event_id], need_vendor: false)
    end
    # render json: @events.to_sql
    # return false

    cust_kosongan = Customer.active.where("name ~* '.*PURA.*' or name ~* '.*RDPI.*' or name ~* '.*RAJAWALI INTI.*'").pluck(:id)

    @events = @events.where("customer_id NOT IN (?)", cust_kosongan).order(:id)
    # fetch_excel()

    @invoice_id = params[:invoice_id]

    if @invoice_id.present?
      @events = Event.where("id = ? and deleted = false", @invoice_id)
    end

    @office_id = params[:office_id]

    if @office_id.present? and @office_id != "all"
        @events = @events.where("office_id = ?", @office_id)
    end

    @offices = Office.active.order('id asc')
    @office_role = []

    if checkrole 'BKK Kantor Sidoarjo'
        @office_role.push(1)
    end
    if checkrole 'BKK Kantor Jakarta'
        @office_role.push(2)
    end
    if checkrole 'BKK Kantor Probolinggo'
        @office_role.push(3)
    end
    if checkrole 'BKK Kantor Semarang'
        @office_role.push(4)
    end
    if checkrole 'BKK Kantor Surabaya'
      @office_role.push(5)
    end
    if checkrole 'BKK Kantor Sumatera'
      @office_role.push(6)
    end
    # if checkrole 'BKK Cargo Padat'
    #   @office_role.push(7)
    # end

    if checkrole 'Operasional BKK'
        @offices = @offices.where('id != 7').order('id asc')
    else
        @offices = @offices.where('id IN (?)', @office_role).order('id asc')
    end


    respond_to :html
  end

  def getdovendor
    url = URI("https://office.8cemerlang.com/events/api/setdovendor?target=pura")
    # url = URI("http://localhost:3001/events/api/setdovendor?target=pura")
		https = Net::HTTP.new(url.host, url.port)
		https.read_timeout = 3600
		https.use_ssl = true
		https.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Get.new(url.request_uri)
		# request["Authorization"] = "Basic #{@api_token}"
		request["Cookie"] = "user.id=Mzg1--7739d955677cf13c461689e01f95ba77f9b9d9f2"

		response = https.request(request)
		result = ActiveSupport::JSON.decode(response.read_body)
		# render json: result['customer']
    # return false

    @customers = []
    result['customer'].each_with_index.map do |customer, i|

      new_customerhash = {
        id: customer['id'],
        name: customer['name']
      }

      @customers.push(new_customerhash)
		end

    @vendors = []
    result['vendors'].each_with_index.map do |vendor, i|

      new_vendorhash = {
        id: vendor['id'],
        name: vendor['name'],
        abbr: vendor['abbr']
      }

      @vendors.push(new_vendorhash)
		end

    @commodities = []
    result['commodities'].each_with_index.map do |commodity, i|

      new_commodityhash = {
        id: commodity['id'],
        name: commodity['name']
      }

      @commodities.push(new_commodityhash)
		end

    @multimoda = ['Truk', 'Truk + Kereta', 'Truk + Kapal']
    render :json => { :success => true, :html => render_to_string(:partial => "events/dovendor", :layout => false) }.to_json;
  end

  def getdovvendors
    url = URI("https://office.8cemerlang.com/events/api/setdovvendors?multimoda=#{params[:multimoda]}")
    # url = URI("http://localhost:3001/events/api/setdovvendors?multimoda=#{params[:multimoda]}")
		https = Net::HTTP.new(url.host, url.port)
		https.read_timeout = 3600
		https.use_ssl = true
		https.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Get.new(url.request_uri)
		# request["Authorization"] = "Basic #{@api_token}"
		request["Cookie"] = "user.id=Mzg1--7739d955677cf13c461689e01f95ba77f9b9d9f2"

		response = https.request(request)
		result = ActiveSupport::JSON.decode(response.read_body)
		# render json: result['customer']
    # return false

    @vendors = []
    result['vendors'].each_with_index.map do |vendor, i|

      new_vendorhash = {
        id: vendor['id'],
        name: vendor['name'],
        abbr: vendor['abbr']
      }

      @vendors.push(new_vendorhash)
		end

    render :json => { :success => true, :html => render_to_string(:partial => "events/dovvendors", :layout => false) }.to_json;
  end

  def getdovroutes
    url = URI("https://office.8cemerlang.com/events/api/setdovroutes?customer_id=#{params[:customer_id]}")
    # url = URI("http://localhost:3001/events/api/setdovroutes?customer_id=#{params[:customer_id]}")
		https = Net::HTTP.new(url.host, url.port)
		https.read_timeout = 3600
		https.use_ssl = true
		https.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Get.new(url.request_uri)
		# request["Authorization"] = "Basic #{@api_token}"
		request["Cookie"] = "user.id=Mzg1--7739d955677cf13c461689e01f95ba77f9b9d9f2"

		response = https.request(request)
		result = ActiveSupport::JSON.decode(response.read_body)
		# render json: result['customer']
    # return false

    @routes = []
    result['routes'].each_with_index.map do |route, i|

      new_routehash = {
        id: route['id'],
        name: route['name']
      }

      @routes.push(new_routehash)
		end

    render :json => { :success => true, :html => render_to_string(:partial => "events/dovroutes", :layout => false) }.to_json;
  end

  def getdovvendorroutes
    url = URI("https://office.8cemerlang.com/events/api/setdovvendorroutes?vendor_id=#{params[:vendor_id]}")
    # url = URI("http://localhost:3001/events/api/setdovvendorroutes?vendor_id=#{params[:vendor_id]}")
		https = Net::HTTP.new(url.host, url.port)
		https.read_timeout = 3600
		https.use_ssl = true
		https.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Get.new(url.request_uri)
		# request["Authorization"] = "Basic #{@api_token}"
		request["Cookie"] = "user.id=Mzg1--7739d955677cf13c461689e01f95ba77f9b9d9f2"

		response = https.request(request)
		result = ActiveSupport::JSON.decode(response.read_body)
		# render json: result['customer']
    # return false

    @vendorroutes = []
    result['vendorroutes'].each_with_index.map do |route, i|

      new_routehash = {
        id: route['id'],
        name: route['name']
      }

      @vendorroutes.push(new_routehash)
		end

    render :json => { :success => true, :html => render_to_string(:partial => "events/dovvendorroutes", :layout => false) }.to_json;
  end

  def transferdov
    orievent = Event.find(params[:event_id])

    url = URI("https://office.8cemerlang.com/events/api/post-dovendor")
    # url = URI("http://localhost:3001/events/api/post-dovendor")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(url.request_uri)
    request["Content-Type"] = "application/json"
    request.body = JSON.dump({
      "event" => {
        "start_date" => orievent.start_date,
        "end_date" => orievent.end_date,
        "company2" => 215,
        "route_id" => params[:route_id],
        "customer_id" => params[:customer_id],
        "summary" => orievent.summary,
        "multimoda" => params[:multimoda],
        "losing" => orievent.losing,
        "event_id" => "PURA DO ##{orievent.id}",
        "vendor_id" => params[:vendor_id],
        "vendorroute_id" => params[:vendorroute_id],
        "commodity_id" => params[:commodity_id],
        "load_date" => orievent.load_date,
        "unload_date" => orievent.unload_date,
        "price_per_type" => orievent.price_per_type,
        "estimated_tonage" => orievent.estimated_tonage,
        "cargo_type" => orievent.cargo_type,
        "tanktype" => orievent.tanktype,
        "qty" => params[:event_qty],
        "truck_quantity" => params[:event_qty],
        "volume" => orievent.volume,
        "description" => orievent.description,
        "oricustomer" => orievent.customer_id
      }
    })

    response = http.request(request)
    @response = response.read_body
    data = JSON.parse(@response)

    if data["status"] == 200
      orievent.need_vendor = true
      orievent.save

      flash[:success] = "Permintaan DO Vendor ke Indolintas 8 Cemerlang berhasil dibuat"
      flash.keep
    else
      flash[:error] = "Permintaan gagal dibuat"
      flash.keep
    end

    redirect_to events_add_dovendor_url
    # render json: data["status"] == 200
  end

  def restore
    @event = Event.find(params[:id])
    @event.deleted = false
    @event.cancelled = false
    @event.reject_reason = nil
    @event.deleteuser_id = nil
    @event.save

    add_eventlog @event.id, 'DO dipulihkan'

    redirect_to(edit_event_url(@event), :notice => 'Data Event / DO berhasil dipulihkan')
  end

  def get_unpaid_inv

    customer_id = params[:customer_id]
    @customer = Customer.find(customer_id) rescue nil
    # @taxinvoice = Taxinvoice.active.where("paiddate is null and customer_id = ?", customer_id)
    @taxinvoice = Taxinvoice.active.where("paiddate IS NULL AND customer_id = ? AND date >= ?", customer_id, Date.new(2022, 1, 1))
    @taxinvoice_total = @taxinvoice.sum(:total)
    @taxinvoice_dp_total = @taxinvoice.sum(:downpayment)
    @taxinvoice_t2_total = @taxinvoice.sum(:secondpayment)
    @taxinvoice_t3_total = @taxinvoice.sum(:thirdpayment)
    @taxinvoice_t4_total = @taxinvoice.sum(:fourthpayment)
    @piutang =  @taxinvoice_total - @taxinvoice_dp_total - @taxinvoice_t2_total - @taxinvoice_t3_total - @taxinvoice_t4_total

    render :json => { :success => true, :html => render_to_string(:partial => "events/unpaid_inv", :layout => false) }.to_json;
  end

end
