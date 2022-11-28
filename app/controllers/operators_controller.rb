class OperatorsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role
  protect_from_forgery :except => [:update_asset]

  def set_section
    @section = "masters"
    @where = "operators"
    @operatortype = ["TRAIN", "MULTIMODE"]
  end

  def set_role
    @user_role = 'Admin Marketing'
  end

  def index
    role = cek_roles @user_role
    if role
      @operators = Operator.all(:order =>:name)
      respond_to :html
    else
      redirect_to root_path()
    end
  end

  def new
    @operator = Operator.new
    @operator.enabled = true
    respond_to :html
  end

  def edit
    @operator = Operator.find(params[:id])

    respond_to :html
  end

  def create
    inputs = params[:operator]
    @operator = Operator.new(inputs)

    if @operator.save
      redirect_to(operators_url(), :notice => 'Data Operator sukses ditambah.')
    else
      redirect_to(new_operator_url(), :notice => 'Data Operator gagal ditambah. Data Harus Unik.')
    end
  end

  def update
    inputs = params[:operator]
    @operator = Operator.find(params[:id])

    if @operator.update_attributes(inputs)
      @operator.save
      redirect_to(edit_operator_url(@operator), :notice => 'Data Operator sukses disimpan.')
    else
      redirect_to(edit_operator_url(@operator), :notice => 'Data Operator gagal disimpan. Data Harus Unik.')
    end
  end

  def destroy
    @operator = Operator.find(params[:id])
    @operator.deleted = true
    @operator.save
    redirect_to(operators_url)
  end  
  
  def enable
    @operator = Operator.find(params[:id])
    @operator.update_attributes(:enabled => true)
    redirect_to(operators_url)
  end
  
  def disable
    @operator = Operator.find(params[:id])
    @operator.update_attributes(:enabled => false)
    redirect_to(operators_url)
  end
end
