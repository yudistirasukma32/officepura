class BookingsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role
  protect_from_forgery :except => [:update_asset]

  def set_section
    @section = "events"
    @where = "bookings"
  end

  def set_role
    @user_role = 'Admin Operasional, Admin HRD, Admin Keuangan, Admin Kendaraan'
  end

  def index
    role = cek_roles @user_role
    if role
      @bookings = Booking.all(:order =>:event_id)
      respond_to :html
    else
      redirect_to root_path()
    end
  end

  def report_bookings

    @date = params[:date]
    @date = Date.today.strftime('%d-%m-%Y') if @date.nil? 
    @bookings = Booking.where("date = ? and deleted is false", @date.to_date)
      
    @office_id = params[:office_id]
      
    if @office_id.present? and @office_id != "all"
        @bookings = Booking.where("office_id = ?", @office_id)
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
    
    if checkrole 'Operasional BKK'
        @offices = @offices.order('id asc')
    else
        @offices = @offices.where('id IN (?)', @office_role).order('id asc')
    end

    render "report-bookings"
  end

  def new
    @process = 'new'
    @booking = Booking.new
    @booking.date = Date.today.strftime('%d-%m-%Y')
    @booking.enabled = true

    @events = Event.where("deleted = false AND end_date >= ?", 3.days.ago).order(:summary)

    respond_to :html
  end

  def edit
    @process = 'edit'
    @booking = Booking.find(params[:id])

    respond_to :html
  end

  def create
    inputs = params[:booking]
    @booking = Booking.new(inputs)
    @booking.user_id = current_user.id
    
    if @booking.save
      redirect_to(bookings_url(), :notice => 'Data Booking sukses ditambah.')
    else
      redirect_to(new_booking_url(), :notice => 'Data Booking gagal ditambah. Data Harus Unik.')
    end
  end

  def update
    inputs = params[:booking]
    @booking = Booking.find(params[:id])

    if @booking.update_attributes(inputs)
      @booking.save
      redirect_to(edit_booking_url(@booking), :notice => 'Data Booking sukses disimpan.')
    else
      redirect_to(edit_booking_url(@booking), :notice => 'Data Booking gagal diedit. Data Harus Unik.')
    end
  end

  def getbookings
    @bookings = Booking.active.where("date >= ?", 2.months.ago).order(:date)
    
    respond_to do |format|
       format.json { render :json => @bookings }
     end
  end

  def destroy
    @booking = Booking.find(params[:id])
    @booking.deleted = true
    @booking.save
    redirect_to(bookings_url)
  end  
  
  def enable
    @booking = Booking.find(params[:id])
    @booking.update_attributes(:enabled => true)
    redirect_to(bookings_url)
  end
  
  def disable
    @booking = Booking.find(params[:id])
    @booking.update_attributes(:enabled => false)
    redirect_to(bookings_url)
  end
end