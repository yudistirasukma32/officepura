class LegalitiesController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_legality
	before_filter :set_legality, only: [:edit, :update, :destroy]

  respond_to :html
	
	def set_section
    @section = "masters"
    @where = "legalities"
  end

  def index
    @legalities = Legality.all
    respond_with(@legalities)
  end

  def new
    @legality = Legality.new
    respond_with(@legality)
  end

  def edit
  	respond_with(@legality)
  end

  def create
    @legality = Legality.new(params[:legality])
    @legality.save
		redirect_to(legalities_path, :notice => 'Data Legal sukses disimpan')
  end

  def update
    if @legality.update_attributes(params[:legality])
      @legality.save
      redirect_to(legalities_path, :notice => 'Data Legal sukses diupdate')
    else
      to_flash(@legality)
      render :action => "edit"
    end
		
		
  end

  def destroy
    @legality = Legality.find(params[:id])
    @legality.deleted = true
    @legality.save
		redirect_to(legalities_path, :notice => 'Data Legal sukses dihapus')
  end

  private
    def set_legality
      @legality = Legality.find(params[:id])
    end
end

