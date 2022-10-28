class EventcleaningmemosController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role
  protect_from_forgery :except => [:update_asset]

  def set_section
    @section = "events"
    @where = "eventcleaningmemos"
  end

  def set_role
    @user_role = 'Admin Keuangan, Admin Marketing, Admin Operasional'
  end

  def index
    role = cek_roles @user_role
    if role
      @eventcleaningmemos = Event.all(:order =>:name)
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

    @eventcleaningmemo = Eventcleaningmemo.new
    @eventcleaningmemo.enabled = true
    respond_to :html
  end

  def edit
    @process = 'edit'
    @iseditable = true
    @eventcleaningmemo = Eventcleaningmemo.find(params[:id])
    @event = Event.find(@eventcleaningmemo.event_id)
    @event_id = @event.id 

    respond_to :html
  end

  def create
    inputs = params[:eventcleaningmemo]
    @event = Event.find(params[:event_id])
    @eventcleaningmemo = Eventcleaningmemo.new
    @eventcleaningmemo.assign_attributes(inputs)
    if @eventcleaningmemo.valid?
      @eventcleaningmemo.save
      flash[:notice] = "Data Cleaning Memo sukses disimpan";
      flash.keep
      render json: { status: 200, url: edit_event_url(@event) }
    else
      render json: { status: 400, errors: @eventcleaningmemo.errors.messages, url: edit_event_url(@event) }, status: 400
    end
  end

  def update
    inputs = params[:eventcleaningmemo]
    @event = Event.find(params[:event_id])
    @eventcleaningmemo = Eventcleaningmemo.find(params[:id])
    @eventcleaningmemo.assign_attributes(inputs)
    if @eventcleaningmemo.valid?
      @eventcleaningmemo.save
      flash[:notice] = "Data Cleaning Memo sukses diperbarui";
      flash.keep
      render json: { status: 200, url: edit_event_url(@event) }
    else
      render json: { status: 400, errors: @eventcleaningmemo.errors.messages, url: edit_event_url(@event) }, status: 400
    end
  end

  def destroy
    @eventcleaningmemo = Eventcleaningmemo.find(params[:id])
    @eventcleaningmemo.deleted = true
    @eventcleaningmemo.save
    # redirect_to(events_url)
    redirect_to(edit_event_url(@eventcleaningmemo.event_id), :notice => 'Data Memo Cleaning sukses dihapus.')
  end  
  
  def enable
    @eventcleaningmemo = Eventcleaningmemo.find(params[:id])
    @eventcleaningmemo.update_attributes(:enabled => true)
    redirect_to(events_url)
  end
  
  def disable
    @eventcleaningmemo = Eventcleaningmemo.find(params[:id])
    @eventcleaningmemo.update_attributes(:enabled => false)
    redirect_to(events_url)
  end

  def print
    @eventcleaningmemo = Eventcleaningmemo.find(params[:id])
    @event = Event.find(@eventcleaningmemo.event_id)
    @routes = Route.where('customer_id = ?', @event.customer_id)

    @quantity_memo = @event.volume.to_i/@event.qty.to_i
    respond_to :html
  end
end
