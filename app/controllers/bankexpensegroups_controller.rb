class BankexpensegroupsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "transactions"
    @where = 'bankexpensegroups'
    @types = ['Debit', 'Kredit']
  end

  def index
    @bankexpensegroups = Bankexpensegroup.where(:deleted => false,:bankexpensegroup_id => nil).order(:name)
    respond_to :html
  end

  def new
    @bankexpensegroup = Bankexpensegroup.new
    @bankexpensegroup.enabled = true
    respond_to :html
  end

  def edit
    @bankexpensegroup = Bankexpensegroup.find(params[:id])
  end

  def create
    inputs = params[:bankexpensegroup]
    @bankexpensegroup = Bankexpensegroup.new(inputs)
    # @bankexpensegroup.total = inputs[:total].delete('.').gsub(",",".")
    @bankexpensegroup.total = 0


    if @bankexpensegroup.save
      redirect_to(edit_bankexpensegroup_url(@bankexpensegroup), :notice => 'Grup Kas Bank sukses di tambah.')
    else
      to_flash(@bankexpensegroup)
      render :action => "new"
    end
  end

  def update
    inputs = params[:bankexpensegroup]
    @bankexpensegroup = Bankexpensegroup.find(params[:id])

    if @bankexpensegroup.update_attributes(inputs)
      @bankexpensegroup.total = inputs[:total].delete('.').gsub(",",".")
      @bankexpensegroup.save
      redirect_to(edit_bankexpensegroup_url(@bankexpensegroup), :notice => 'Grup Kas Bank sukses di simpan.')
    else
      to_flash(@bankexpensegroup)
      render :action => "edit"
    end
  end

  def destroy
    @bankexpensegroup = Bankexpensegroup.find(params[:id])
    @bankexpensegroup.deleted = true
    @bankexpensegroup.save

    puts "MSUK"
    redirect_to(bankexpensegroups_url)
  end  
  
  def enable
    @bankexpensegroup = Bankexpensegroup.find(params[:id])
    @bankexpensegroup.update_attributes(:enabled => true)
    redirect_to(bankexpensegroups_url)
  end
  
  def disable
    @bankexpensegroup = Bankexpensegroup.find(params[:id])
    @bankexpensegroup.update_attributes(:enabled => false)
    redirect_to(bankexpensegroups_url)
  end

  def inReportEnable
    @bankexpensegroup = Bankexpensegroup.find(params[:id])
    @bankexpensegroup.update_attributes(:inreport => true)
    redirect_to(bankexpensegroups_url)
  end

  def inReportDisable
    @bankexpensegroup = Bankexpensegroup.find(params[:id])
    @bankexpensegroup.update_attributes(:inreport => false)
    redirect_to(bankexpensegroups_url)
  end
end
