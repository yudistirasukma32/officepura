class TaxinvoiceitemapiController < ApplicationController
    include ApplicationHelper
    include ActionView::Helpers::NumberHelper
	
	def detail
        u = Invoice.find(params[:id])
        
        @invoice = { 
                :id => u.id,
                :do => u.event_id, 
                :deleted => u.deleted, 
                :date => u.date, 
                :quantity => u.quantity, 
                :total => u.total, 
                :vehicle => u.vehicle.current_id, 
                :driver_name => u.driver.name, 
                :driver_phone => u.driver.phone, 
                :driver_mobile => u.driver.mobile, 
                :route => u.route.name, 
                :customer_name => u.customer.name,
                :invoicetrain => u.invoicetrain,
                :tanktype => u.tanktype,
                :isotank_number => (u.isotank.isotanknumber rescue nil),
                :container_number => (u.container.containernumber rescue nil)
            }
		
		@taxinvoiceitems = Taxinvoiceitem.where("invoice_id = ?", params[:id])
 
		@type = "Invoice"
		
		@invoiceImg = Attachment.where("imageable_type = ? and imageable_id = ?", @type, u.id)
		
		@invoiceImgs = @invoiceImg.map do |u|
			{ :id => u.id, :imgUrl => u.file.thumb('240x240').url(:suffix => "/#{u.name}") }
		end	
		
		if @invoice.blank?
			render json: {
			message: 'Not Found',
			status: 404,
			}, status: 404
		else
			render json: {
			message: 'Success',
			status: 200,
      invoice: u,
			detail: @invoice,
      taxinvoiceitems: @taxinvoiceitems,
			images: @invoiceImgs,	
			}, status: 200
		end
			
	end
    
  def updateitems
    inputs = params["taxinvoiceitems"]

    @invoice = Invoice.find(inputs[:invoice_id])
    
    if @invoice.taxinvoiceitems.any?
      @invoice.taxinvoiceitems.each do |item|
        item_id = item.id.to_s
        if inputs["total_" + item_id] != "0" and item.taxinvoice_id.nil?
          item.date = inputs["date_" + item_id]
          item.sku_id = inputs["sku_id_" + item_id]
          item.weight_gross = inputs["weight_gross_" + item_id].blank? ? 0 : inputs["weight_gross_" + item_id]
          item.load_date = inputs["load_date_" + item_id]
          item.weight_net = inputs["weight_net_" + item_id].blank? ? 0 : inputs["weight_net_" + item_id]
          item.unload_date = inputs["unload_date_" + item_id]
          item.price_per = @invoice.price_per.to_f
          item.total = item.price_per.to_f >= 300000 ? item.price_per.to_f : item.price_per.to_f * item.weight_net
          item.office_id = @invoice.office_id
          item.customer_id = @invoice.customer_id
          item.wholesale_price = inputs["wholesale_price"].to_f
          item.save
        end
      end
      
        render json: {
        message: 'Success Update SJ',
        status: 200,
        invoice: @invoice,
        taxinvoiceitems: @invoice.taxinvoiceitems,
        }, status: 200
        
    else
        
        render json: {
        message: 'Failed Update SJ',
        status: 400,
        }, status: 400   
    
    end    
  end

end