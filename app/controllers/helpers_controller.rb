class HelpersController < ApplicationController

  def create
    inputs = params[:helper]
    @helper = Helper.new(inputs)
    @driver = Driver.find(inputs[:driver_id])

    if @helper.save
      redirect_to(edit_driver_url(@driver), :notice => 'Data Kernet sukses di simpan.')
    end
  end

  def update
    inputs = params[:helper]
    @helper = Helper.find(params[:id])
    @driver = Driver.find(inputs[:driver_id])

    if @helper.update_attributes(inputs)
      @helper.save
      redirect_to(edit_driver_url(@driver), :notice => 'Data Kernet sukses di simpan.')
    end
  end

  def destroy
    @helper = Helper.find(params[:id])
    @helper.deleted = true
    @helper.save
    redirect_to(helpers_url)
  end  
  
end
