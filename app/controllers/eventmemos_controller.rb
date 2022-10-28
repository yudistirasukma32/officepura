class EventmemosController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role
  protect_from_forgery :except => [:update_asset]

  def set_section
    @section = "events"
    @where = "eventsmemo"
  end

  def set_role
    @user_role = 'Admin Keuangan, Admin Marketing, Admin Operasional'
  end

  def index
    role = cek_roles @user_role
    if role
      @eventmemos = Eventmemo.all(:order =>:name)
      respond_to :html
    else
      redirect_to root_path()
    end
  end

  def new
    @process = 'new'
    @iseditable = true
    @event_id = params[:event_id]
    @event = Event.find(params[:event_id])
    @routes = Route.where('customer_id = ?', @event.customer_id)

    @quantity_memo = @event.volume.to_i/@event.qty.to_i

    @eventmemo = Eventmemo.new
    @eventmemo.enabled = true
    respond_to :html
  end

  def edit
    @process = 'edit'
    @iseditable = true
    @eventmemo = Eventmemo.find(params[:id])
    @event = Event.find(@eventmemo.event_id)
    @event_id = @event.id
    @routes = Route.where('customer_id = ?', @eventmemo.customer_id)

    respond_to :html
  end

  def create
    inputs = params[:eventmemo]
    @eventmemo = Eventmemo.new
    @event = Event.find(params[:event_id])
    
    @eventmemo.assign_attributes(inputs)
    if @eventmemo.valid?
      @eventmemo.save
      flash[:notice] = "Data Memo sukses dibuat";
      flash.keep
      render json: { status: 200, url: edit_event_url(@event) }
    else
      render json: { status: 400, errors: @eventmemo.errors.messages, url: edit_event_url(@event) }, status: 400
    end
  end

  def update
    inputs = params[:eventmemo]
    @eventmemo = Eventmemo.find(params[:id])
    @event = Event.find(@eventmemo.event_id)
    @eventmemo.assign_attributes(inputs)
    if @eventmemo.valid?
      @eventmemo.save
      flash[:notice] = "Data Memo sukses diperbarui";
      flash.keep
      render json: { status: 200, url: edit_event_url(@event) }
    else
      render json: { status: 400, errors: @eventmemo.errors.messages, url: edit_event_url(@event) }, status: 400
    end
  end

  def destroy
    @eventmemo = Eventmemo.find(params[:id])
    @eventmemo.deleted = true
    @eventmemo.save
    redirect_to(edit_event_url(@eventmemo.event_id), :notice => 'Data Memo sudah dihapus.')
  end  
  
  def enable
    @eventmemo = Eventmemo.find(params[:id])
    @eventmemo.update_attributes(:enabled => true)
    redirect_to(events_url)
  end
  
  def disable
    @eventmemo = Eventmemo.find(params[:id])
    @eventmemo.update_attributes(:enabled => false)
    redirect_to(events_url)
  end

  def print
    @eventmemo = Eventmemo.find(params[:id])
    @event = Event.find(@eventmemo.event_id)
    @routes = Route.where('customer_id = ?', @event.customer_id)
    
    @quantity_memo = @event.volume.to_i/@event.qty.to_i
  end

  def delete
    @eventmemo = Eventmemo.find(params[:id])
    @eventmemo.deleted = true
    @eventmemo.save
    redirect_to(edit_event_url(@eventdemo.event_id))
  end
end
