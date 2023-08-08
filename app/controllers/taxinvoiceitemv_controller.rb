class TaxinvoiceitemvController < ApplicationController
  protect_from_forgery with: :null_session,
  if: Proc.new { |c| c.request.format =~ %r{application/json} }

  def postapi_taxinvoiceitemv
    # puts "LOG : #{params[:_json].blank?}"
    if params[:_json].present?
      params[:_json].each do |item|
        # puts "LOG : #{item[:oripurchaseorder]}"
        itemv = Taxinvoiceitemv.active.where(oriitem: item[:oriitem]).first
        if itemv.present?
          if itemv.taxinvoice_id.blank?
            itemv.sku_id = item[:sku_id]
            itemv.date = item[:date]
            itemv.vehicle_number = item[:vehicle_number]
            itemv.weight_gross = item[:weight_gross]
            itemv.weight_net = item[:weight_net]
            itemv.event_id = item[:event_id]
            itemv.customer_id = item[:customer_id]
            itemv.load_date = item[:load_date]
            itemv.unload_date = item[:unload_date]
            itemv.price_per = item[:price_per]
            itemv.total = item[:total]
            itemv.wholesale_price = item[:wholesale_price]

            itemv.save
          end
        else
          taxinvoiceitemv = Taxinvoiceitemv.new(item)
          taxinvoiceitemv.save
        end
      end
    end
  end
end