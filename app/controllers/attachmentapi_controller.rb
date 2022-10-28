class AttachmentapiController < ApplicationController
 
  def upload
    @attachment = Attachment.new()
    @attachment.file = params[:file]
    @attachment.name = params[:name]
    @attachment.imageable_type = params[:model_name].capitalize
    @attachment.imageable_id = params[:item_id]
    @attachment.enabled = true
    @attachment.media = false
    @attachment.save

		render json: {
		message: 'Upload Assets Success',
		status: 200,
		}, status: 200
		
  end
	
    def uploadTaxInv 
        @attachment = Attachment.new()
        @attachment.file = params[:file]
        @attachment.name = params[:name]
        @attachment.imageable_type = params[:model_name].capitalize
        @attachment.imageable_id = params[:item_id]
        @attachment.enabled = true
        @attachment.media = false
        @attachment.save
        render json: {
        message: 'Upload Taxinvoice Success',
        status: 200,
        }, status: 200

    end	

  def remove
    @attachment = Attachment.find(params[:id])
    path = get_parent_edit_path(@attachment.imageable_type, @attachment.imageable_id)
    @attachment.destroy
#    redirect_to(path)
		
		render json: {
		message: 'Remove Assets Success',
		status: 200,
		}, status: 200
		
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
    when "Supplier"
        edit_supplier_url(id)
    when "Staff"
        edit_staff_url(id)
    when "Vehicle"
        edit_vehicle_url(id) 
    when "Legality"
        edit_legality_url(id)
    when "Invoice"
        edit_invoice_url(id)  
    end
  end
end
