class AttachmentsController < ApplicationController
	include ApplicationHelper
	layout "application"
  protect_from_forgery :except => [:upload, :remove, :uploadTaxInv, :uploadQuot]

  def upload
    inputs = params[:attachment]
    @attachment = Attachment.new()
    @attachment.file = inputs[:file]
    @attachment.name = inputs[:name]
    @attachment.imageable_type = params[:model_name].capitalize
    @attachment.imageable_id = params[:item_id]
    @attachment.enabled = true
    @attachment.media = false
    @attachment.save
    redirect_to(get_parent_edit_path(params[:model_name].capitalize, params[:item_id]), :notice => 'File sukses di simpan.')
  end

  def remove
    @attachment = Attachment.find(params[:id])
    path = get_parent_edit_path(@attachment.imageable_type, @attachment.imageable_id)
    @attachment.destroy
    redirect_to(path)
  end

  def uploadQuot
		inputs = params[:attachment]
    @attachment = Attachment.new()
    @attachment.file = inputs[:file]
    @attachment.name = inputs[:name]
    @attachment.imageable_type = params[:model_name].capitalize
    @attachment.imageable_id = params[:item_id]
    @attachment.enabled = true
    @attachment.media = false
    @attachment.save
#    redirect_to(get_parent_edit_path(params[:model_name].capitalize, params[:item_id]), :notice => 'File sukses di simpan.')
		redirect_to("/quotationgroups/" + params[:item_id] +'/edit',  :notice => 'File sukses disimpan.')    
	end

  def removeQuot
    @attachment = Attachment.find(params[:id])
    @attachment.destroy
    redirect_to("/quotationgroups/" + @attachment.imageable_id.to_s + '/edit', :notice => 'File berhasil dihapus.')        
	end

  def uploadTaxInv
		inputs = params[:attachment]
    @attachment = Attachment.new()
    @attachment.file = inputs[:file]
    @attachment.name = inputs[:name]
    @attachment.imageable_type = params[:model_name].capitalize
    @attachment.imageable_id = params[:item_id]
    @attachment.enabled = true
    @attachment.media = false
    @attachment.save
#    redirect_to(get_parent_edit_path(params[:model_name].capitalize, params[:item_id]), :notice => 'File sukses di simpan.')
		redirect_to("/taxinvoiceitems/new/" + params[:item_id], :notice => 'File sukses disimpan.')    
	end

	def removeTaxInv
    @attachment = Attachment.find(params[:id])
    @attachment.enabled = false
    @attachment.save
    redirect_to("/taxinvoiceitems/new/" + @attachment.imageable_id.to_s, :notice => 'File berhasil dihapus.')  
	end

  def showimages
  end

  def get_parent_edit_path name, id
    case name
    when "Customer"
      edit_customer_url(id)
    when "Product"
      edit_product_url(id)
    when "Driver"
      edit_driver_url(id)
    when "Helper"
      edit_helper_url(id)
    when "Supplier"
      edit_supplier_url(id)
    when "Staff"
      edit_staff_url(id)
    when "Vehicle"
      edit_vehicle_url(id)
    when "Office"
      edit_office_url(id)
    when "Legality"
      edit_legality_url(id)
    when "Invoice"
			edit_invoice_url(id)
    when "Taxinvoice"
			edit_taxinvoice_url(id)  
    when "Taxinvoiceattachment"
      edit_taxinvoiceattachment_url(id)   
    when "Claimmemo"
      edit_claimmemo_url(id)   
    when "Quotationgroup"
			edit_quotationgroup_url(id)    
    end
  end

end