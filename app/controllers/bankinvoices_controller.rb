class BankinvoicesController < ApplicationController
  include ApplicationHelper
  layout "application"
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "transactions"
    @where = "bankinvoices"
    @types = ['Debit', 'Kredit']
  end

  def index
    @date = params[:date]
    @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
    # @bankinvoices = Bankinvoice.where("to_char(date, 'DD-MM-YYYY') = ?", @date).order(:id)
    @bankgroup_id = Bankexpensegroup.active.parentgroup.where("name LIKE 'BANK'").first.id

    @bankinvoices = Bankexpense.where("bankledger IS TRUE AND to_char(date, 'DD-MM-YYYY') = ?", @date).order(:id)
  end

  def new
    @parentgroups = Bankexpensegroup.active.parentgroup.where("name NOT LIKE 'PETTY KAS'").order(:name)

    @bank_id = Bankexpensegroup.active.parentgroup.where("name LIKE 'BANK'").first.id

    @bankexpense = Bankexpense.new
    # @bankinvoice.enabled = true
    @bankexpense.office_id = current_user.office_id rescue nil || 1 
    @bankexpense.date = Date.today.strftime('%d-%m-%Y')
    # respond_to :html
  end
  
  def print
    @bankinvoice = Bankexpense.find(params[:id])
  end
end
