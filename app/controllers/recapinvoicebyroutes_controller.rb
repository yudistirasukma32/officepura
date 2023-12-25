class RecapinvoicebyroutesController < ApplicationController

  def index

  end

  def excelbyroutes
    filename = "rekap_invoice_pelanggan_" + params[:year] + ".xls"
    customer_ids = Taxinvoice.active.where("EXTRACT(YEAR FROM date)=?", params[:year]).pluck(:customer_id).uniq
    customers = Customer.where(deleted: false, id: customer_ids).order(:name)

    # Sheet
    p = Axlsx::Package.new
    p.workbook.add_worksheet(:name => "Rekap Invoice") do |sheet|

      # Style
      bold = sheet.styles.add_style(:b => true)
      right = sheet.styles.add_style(:alignment => {:horizontal => :right})
      right_currency = sheet.styles.add_style(:alignment => {:horizontal => :right}, :format_code => "#,##0.00;[Red]-#,##0.00")
      right_bold = sheet.styles.add_style(:alignment => {:horizontal => :right}, :b => true)
      right_bold_currency = sheet.styles.add_style(:alignment => {:horizontal => :right}, :b => true, :format_code => "#,##0.00;[Red]-#,##0.00")
      border_b = sheet.styles.add_style(:border => {:style => :thick, :color => '000000', :edges => [:bottom]})

      # Excel content
      sheet.add_row ['','NO.', 'PELANGGAN', 'JANUARI', 'FEBRUARI', 'MARET', 'APRIL', 'MEI', 'JUNI', 'JULI', 'AGUSTUS', 'SEPTEMBER', 'OKTOBER', 'NOVEMBER', 'DESEMBER', 'TOTAL'], :height => 20, :style => [bold,bold,bold,right_bold,right_bold,right_bold,right_bold,right_bold,right_bold,right_bold,right_bold,right_bold,right_bold,right_bold,right_bold,right_bold]

      customers.each_with_index do |customer, i|

        # Get invoices value from january to december
        january = Taxinvoice.active.where(customer_id: customer.id).where("EXTRACT(YEAR FROM date)=? AND EXTRACT(MONTH FROM date)=?", params[:year], '01').sum(:total).to_i;
        february = Taxinvoice.active.where(customer_id: customer.id).where("EXTRACT(YEAR FROM date)=? AND EXTRACT(MONTH FROM date)=?", params[:year], '02').sum(:total).to_i;
        march = Taxinvoice.active.where(customer_id: customer.id).where("EXTRACT(YEAR FROM date)=? AND EXTRACT(MONTH FROM date)=?", params[:year], '03').sum(:total).to_i;
        april = Taxinvoice.active.where(customer_id: customer.id).where("EXTRACT(YEAR FROM date)=? AND EXTRACT(MONTH FROM date)=?", params[:year], '04').sum(:total).to_i;
        may = Taxinvoice.active.where(customer_id: customer.id).where("EXTRACT(YEAR FROM date)=? AND EXTRACT(MONTH FROM date)=?", params[:year], '05').sum(:total).to_i;
        june = Taxinvoice.active.where(customer_id: customer.id).where("EXTRACT(YEAR FROM date)=? AND EXTRACT(MONTH FROM date)=?", params[:year], '06').sum(:total).to_i;
        july = Taxinvoice.active.where(customer_id: customer.id).where("EXTRACT(YEAR FROM date)=? AND EXTRACT(MONTH FROM date)=?", params[:year], '07').sum(:total).to_i;
        august = Taxinvoice.active.where(customer_id: customer.id).where("EXTRACT(YEAR FROM date)=? AND EXTRACT(MONTH FROM date)=?", params[:year], '08').sum(:total).to_i;
        september = Taxinvoice.active.where(customer_id: customer.id).where("EXTRACT(YEAR FROM date)=? AND EXTRACT(MONTH FROM date)=?", params[:year], '09').sum(:total).to_i;
        october = Taxinvoice.active.where(customer_id: customer.id).where("EXTRACT(YEAR FROM date)=? AND EXTRACT(MONTH FROM date)=?", params[:year], '10').sum(:total).to_i;
        november = Taxinvoice.active.where(customer_id: customer.id).where("EXTRACT(YEAR FROM date)=? AND EXTRACT(MONTH FROM date)=?", params[:year], '11').sum(:total).to_i;
        december = Taxinvoice.active.where(customer_id: customer.id).where("EXTRACT(YEAR FROM date)=? AND EXTRACT(MONTH FROM date)=?", params[:year], '12').sum(:total).to_i;
        # render json: sheet.rows.last.index
        # return false

        sheet.add_row ['', (i+1).to_s + '.', customer.name, january, february, march, april, may, june, july, august, september, october, november, december, "=SUM(D" + (sheet.rows.last.index + 2).to_s + ":O" + (sheet.rows.last.index + 2).to_s + ")"], :height => 20, :style => [nil,nil,nil,right_currency,right_currency,right_currency,right_currency,right_currency,right_currency,right_currency,right_currency,right_currency,right_currency,right_currency,right_currency,right_currency]
      end

      sheet.add_row [''], :height => 20
    end

    p.use_autowidth = false
    p.use_shared_strings = true

    send_data(p.to_stream.read, :filename => filename, :type => :xls, :x_sendfile => true)

  end
end
