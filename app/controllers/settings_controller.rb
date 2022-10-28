class SettingsController < ApplicationController
	include ApplicationHelper
  include ActionView::Helpers::NumberHelper
	layout "application", :except => []
  before_filter :authenticate_user!, :set_section, :checkrole

  def checkrole
    if !current_user.owner
      redirect_to "/notauthorized" and return false
    end
    return true  
  end

  def set_section
    @section = "settings"
    @where = "settings"
  end

  def index
    @settings = Setting.order(:name)

    @settings.each do |setting|
      if setting.name.upcase == 'BUDGET PEMBELIAN' or setting.name.upcase == 'SALDO KAS KANTOR'  or setting.name.upcase == 'SALDO AKHIR JALAN'
        setting.value = to_currency(setting.value)
      end
    end
  end

  def edit
    @setting = Setting.find(params[:id])
  end

  def update
    @setting = Setting.find(params[:id])

    if @setting.update_attributes(params[:setting])
      @setting.save
      redirect_to(edit_setting_url(@setting), :notice => @setting.name + ' sukses di simpan.')
    else
      to_flash(@setting)
      render :action => "edit"
    end
  end  

end
