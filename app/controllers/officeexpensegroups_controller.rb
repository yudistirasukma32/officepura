class OfficeexpensegroupsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "transactions"
    @where = "officeexpensegroups"
  end

  def index
    @officeexpensegroups = Officeexpensegroup.where(:deleted => false,:officeexpensegroup_id => nil).order(:name)
    respond_to :html
  end

  def new
    @officeexpensegroup = Officeexpensegroup.new
    @officeexpensegroup.enabled = true
    respond_to :html
  end

  def edit
    @officeexpensegroup = Officeexpensegroup.find(params[:id])
  end

  def create
    inputs = params[:officeexpensegroup]
    @officeexpensegroup = Officeexpensegroup.new(inputs)

    if @officeexpensegroup.save
      redirect_to(edit_officeexpensegroup_url(@officeexpensegroup), :notice => 'Grup Kas Kantor sukses di tambah.')
    else
      to_flash(@officeexpensegroup)
      render :action => "new"
    end
  end

  def update
    inputs = params[:officeexpensegroup]
    @officeexpensegroup = Officeexpensegroup.find(params[:id])

    if @officeexpensegroup.update_attributes(inputs)
      @officeexpensegroup.save
      redirect_to(edit_officeexpensegroup_url(@officeexpensegroup), :notice => 'Grup Kas Kantor sukses di simpan.')
    else
      to_flash(@officeexpensegroup)
      render :action => "edit"
    end
  end

  def destroy
    @officeexpensegroup = Officeexpensegroup.find(params[:id])
    @officeexpensegroup.deleted = true
    @officeexpensegroup.save
    redirect_to(officeexpensegroups_url)
  end  
  
  def enable
    @officeexpensegroup = Officeexpensegroup.find(params[:id])
    @officeexpensegroup.update_attributes(:enabled => true)
    redirect_to(officeexpensegroups_url)
  end
  
  def disable
    @officeexpensegroup = Officeexpensegroup.find(params[:id])
    @officeexpensegroup.update_attributes(:enabled => false)
    redirect_to(officeexpensegroups_url)
  end
end
