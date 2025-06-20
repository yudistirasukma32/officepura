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

      # @claimmemos = Claimmemo.active.where('approved = false or approved_by_gm = false')
      @claimmemos = Claimmemo.active.where('approved_marketing = false')

      @confirmed_quotation = Quotationgroup.active.pluck(:id)
      @quotation = Quotation.active.where('quotationgroup_id in (?)', @confirmed_quotation).pluck(:id)
      @allowances = Allowance.active.where('driver_trip = money(0)').pluck(:route_id)
      # @new_routes = Route.active.where('quotation_id in (?) and id in (?)', @quotation, @allowances)
      @new_routes = Route.active
        .where('quotation_id IN (?) AND id IN (?) AND created_at >= ?', @quotation, @allowances, 30.days.ago)

      @quotationgroups = Quotationgroup.active.where('date >= ?', Date.new(2025, 1, 1)).reorder('date DESC')
      @quotationgroups = @quotationgroups.where('confirmed = false')
      
      @draft_routes = Route.active.where('approved = false')
      respond_to :html
    else
      redirect_to root_path()
    end
  end

end