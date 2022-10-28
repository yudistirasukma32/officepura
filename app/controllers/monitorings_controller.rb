class MonitoringsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role
  protect_from_forgery :except => [:update_asset]

  def set_section
    @section = "monitoring"
    @where = "monitoring"
  end

  def set_role
    @user_role = ''
  end

  def index
    role = cek_roles @user_role
    if role
      respond_to :html
    else
      redirect_to root_path()
    end
  end

end