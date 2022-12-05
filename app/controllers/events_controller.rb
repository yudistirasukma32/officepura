class EventsController < ApplicationController
	include ApplicationHelper
  include ActionView::Helpers::NumberHelper
	layout "application", :except => [:getevents]
  before_filter :authenticate_user!, :set_section

  def set_section
   	@section = "events"
    query = params[:type] ? "-cancelled" : ""
    @where = "events" + query
    @estimated_tonage = [20000, 25000, 30000, 35000, 40000]
    @tanktype = ['ISOTANK', 'LOSBAK', 'DROPSIDE', 'TANGKI BESI', 'TANGKI STAINLESS', 'KONTAINER', 'TRUK BOX']
  end

  def index
  end

  def new
    @process = 'new'
    @event = Event.new
    @event.start_date = Date.today.strftime('%d-%m-%Y')
    @event.end_date = Date.today.strftime('%d-%m-%Y')
    @isdelete = false
  end

  def edit
    @process = 'edit' 
    @event = Event.find(params[:id])
    @event.start_date = @event.start_date.strftime('%d-%m-%Y') if !@event.start_date.blank?
    @event.end_date = @event.end_date.strftime('%d-%m-%Y') if !@event.end_date.blank?
    @isdelete = true
      

    @eventmemos = Eventmemo.active.where('event_id = ?', @event.id)
    @eventcleaningmemos = Eventcleaningmemo.active.where('event_id = ?', @event.id)

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
    @event.save 
    redirect_to(events_path)
  end

  def get_event_by_customer

    customer_id = params[:customer_id]
    is_train = params[:train]


    if customer_id == "50" || customer_id == "51" || customer_id == "144"

      @events = Event.active.where("end_date BETWEEN current_date - interval '9' day AND current_date + interval '4' day").order(:start_date)
      render :json => { :success => true, :html => render_to_string(:partial => "invoices/events", :layout => false) }.to_json; 

    else
        
        if is_train == "0"

          @events = Event.active.where("customer_id = ? AND end_date BETWEEN current_date - interval '1' day AND current_date + interval '2' day AND invoicetrain = false", params[:customer_id]).order(:start_date)
          render :json => { :success => true, :html => render_to_string(:partial => "invoices/events", :layout => false) }.to_json; 

        else

          @events = Event.active.where("customer_id = ? AND end_date BETWEEN current_date - interval '9' day AND current_date + interval '4' day AND invoicetrain = true", params[:customer_id]).order(:start_date)
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
      @events = Event.active.where("cancelled = false and start_date >= ?", 3.months.ago).order(:id)
        
      invoices = Invoice.active.select('event_id').where("date >= ?", 3.months.ago).pluck(:event_id)    
        
      @events = @events.map do |e|
          
                half_completed = false
                completed = false
                invoiced = false
                train = false
                completed_by_vendor = false
          
                bkk = ''
                taxinvoice = ''
                event_qty = 1      
          
                if e.qty
                    event_qty = e.qty
                end

                if e.need_vendor
                  completed_by_vendor = true
                end
                
                if invoices.index(e.id)
                    
                    bkk = Invoice.active.select('event_id').where('event_id = ?', e.id).where('id not in (select invoice_id from invoicereturns where deleted = false)').pluck(:id) 
#                    bkk = Invoice.active.select('event_id').where('event_id = ?', e.id).where().pluck(:id) 
                    
                    if bkk.count > 0
                        
                        this_bkk = Invoice.active.select('id, invoicetrain, quantity').find(bkk[0])
                        
                        #Check BKK train/not
                        if this_bkk.invoicetrain
                            
                            train = true
                            
                            #Check QTY of BKK match / not with QTY on event
                            if bkk.count >= event_qty.to_i*2
                                
                                completed = true
                                
                                taxinvoices = Taxinvoiceitem.active.select('invoice_id, total').where("taxinvoiceitems.invoice_id IN (?) AND taxinvoiceitems.total > '0'", bkk).pluck(:id)

                                if taxinvoices.count >= bkk.count / 2

                                  invoiced = true

                                end
  
                            else
                                
                                half_completed = true
                                completed = false
                                
                                if e.need_vendor
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

                                if taxinvoices.count >= bkk.count

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
                    :authorised => e.authorised,
                    :summary => summary,
                    :cancelled => e.cancelled,
                    :start_date => e.start_date,
                    :end_date => e.end_date,
                    :customer_id => e.customer_id,
                    :bkk => bkk,
                    :invoicetrain => train,
                    :half_completed => half_completed,
                    :completed => completed,
                    :completed_by_vendor => completed_by_vendor,
                    :invoiced => invoiced,
                    :sj => taxinvoices
                }
          
                end
    end
    
    respond_to do |format|
       format.json { render :json => @events }
     end
  end


  def report_events

    @where = 'report-events'
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

end