class ApprovalsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role

  def set_section
    @section = "approvals"
    @where = "approvals"
  end

  def set_role
    @user_role = 'Admin Approval, General Manager, Admin Klaim, Admin Approval Klaim, Admin Marketing, Admin Operasional'
  end

  def index
    role = cek_roles @user_role
    if role

      @new_customers = Customer.active.unverified

      @claimmemos = Claimmemo.active.where('approved = false or approved_by_gm = false')

      @confirmed_quotation = Quotationgroup.active.pluck(:id)
      @quotation = Quotation.active.where('quotationgroup_id in (?)', @confirmed_quotation).pluck(:id)
      @allowances = Allowance.active.where('driver_trip = money(0)').pluck(:route_id)
      @new_routes = Route.active.where('quotation_id in (?) and id in (?)', @quotation, @allowances)

      @quotationgroups = Quotationgroup.active.where('date >= ?', Date.new(2024, 1, 1)).reorder('date DESC')
      @quotationgroups = @quotationgroups.where('reviewed = false OR confirmed = false')
      
      respond_to :html
    else
      redirect_to root_path()
    end
  end

end