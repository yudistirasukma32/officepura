class CashiersController < ApplicationController
	include ApplicationHelper
	include ActionView::Helpers::NumberHelper
	layout "application", :except => [:getrequests]
	before_filter :authenticate_user!, :set_section

  def set_section
		@section = "cashiers"
		@where = "cashiers"
	end

	def index
    @date = params[:date]
    @date = Date.today.strftime('%d-%m-%Y') if @date.nil? 

		@receipts = Receipt.active.joins(:invoice).where("invoices.invoicetrain = false AND to_char(receipts.created_at, 'DD-MM-YYYY') = ?", @date).order(:office_id)
		@receipt_invtrains = Receipt.active.joins(:invoice).where("invoices.invoicetrain = true AND to_char(receipts.created_at, 'DD-MM-YYYY') = ?", @date).order(:office_id)
		
		@receiptreturns = Receiptreturn.active.where("to_char(created_at, 'DD-MM-YYYY') = ?", @date).order(:office_id)
		@receiptpremis = Receiptpremi.active.where("to_char(created_at, 'DD-MM-YYYY') = ?", @date)
		@receiptorders = Receiptorder.active.where("to_char(created_at, 'DD-MM-YYYY') = ?", @date)
		@receiptexpenses = Receiptexpense.active.where("to_char(created_at, 'DD-MM-YYYY') = ?", @date)
		@receiptsales = Receiptsale.active.where("to_char(created_at, 'DD-MM-YYYY') = ?", @date)
		@receiptincentives = Receiptincentive.active.where("to_char(created_at, 'DD-MM-YYYY') = ?", @date)
		
		@receiptdrivers = Receiptdriver.active.where("to_char(created_at, 'DD-MM-YYYY') = ?", @date)
		@receiptpayrolls = Receiptpayroll.active.where("to_char(created_at, 'DD-MM-YYYY') = ?", @date)
		@receiptpayrollreturns = Receiptpayrollreturn.active.where("to_char(created_at, 'DD-MM-YYYY') = ?", @date)

		@receipttrains = Receipttrain.active.where("to_char(created_at, 'DD-MM-YYYY') = ?", @date)
		@receiptships = Receiptship.active.where("to_char(created_at, 'DD-MM-YYYY') = ?", @date)
		@receiptinsurances = Receiptinsurance.active.where("to_char(created_at, 'DD-MM-YYYY') = ?", @date)
	end

	def getrequests
    @date = params[:date]
    @date = Date.today.strftime('%d-%m-%Y') if @date.nil? 

		@invoices = Invoice.find_by_sql("SELECT * FROM invoices where kosongan = false and by_vendor = false and invoicetrain = false AND date = '#{@date.to_date}' AND deleted = false AND id not in (SELECT invoice_id FROM receipts where deleted = false)")
		@invoice_kosongan_np = Invoice.find_by_sql("SELECT * FROM invoices where kosongan = true and kosongan_type = 'non-produktif' and kosongan_confirmed = true and by_vendor = false and invoicetrain = false AND date = '#{@date.to_date}' AND deleted = false AND id not in (SELECT invoice_id FROM receipts where deleted = false)")
		@invoice_kosongan_p = Invoice.find_by_sql("SELECT * FROM invoices where kosongan = true and kosongan_type = 'produktif' and by_vendor = false and invoicetrain = false AND date = '#{@date.to_date}' AND deleted = false AND id not in (SELECT invoice_id FROM receipts where deleted = false)")
		@invoicetrains = Invoice.find_by_sql("SELECT * FROM invoices where by_vendor = false and invoicetrain = true AND date = '#{@date.to_date}' AND deleted = false AND id not in (SELECT invoice_id FROM receipts where deleted = false)")

		@invoicereturns = Invoicereturn.find_by_sql("SELECT * FROM invoicereturns where date = '#{@date.to_date}' AND deleted = false AND id not in (SELECT id from invoicereturns where id in (SELECT invoicereturn_id FROM receiptreturns where deleted = false))") 
		@bonusreceipts = Bonusreceipt.find_by_sql("SELECT * FROM bonusreceipts where to_char(created_at, 'DD-MM-YYYY') = '#{@date}' AND deleted = false AND money(total) > money(0) AND invoice_id not in (SELECT invoice_id FROM receiptpremis where deleted = false)")
		@sales = Sale.find_by_sql("SELECT * FROM sales where date = '#{@date.to_date}' AND deleted = false AND id not in (SELECT sale_id FROM receiptsales where deleted = false)") 
		@driverexpenses = Driverexpense.find_by_sql("SELECT * FROM driverexpenses where date = '#{@date.to_date}' AND deleted = false AND id not in (SELECT driverexpense_id FROM receiptdrivers where deleted = false)") 
		@incentives = Incentive.find_by_sql("SELECT * FROM incentives where to_char(created_at, 'DD-MM-YYYY') = '#{@date}' AND deleted = false AND money(total) > money(0) AND invoice_id not in (SELECT invoice_id FROM receiptincentives where deleted = false)")

		@productorders = Productorderitem.find_by_sql("SELECT DISTINCT i.productorder_id FROM productorderitems i INNER JOIN productorders o ON i.productorder_id = o.id WHERE i.bon = false AND o.date = '#{@date.to_date}' AND o.deleted = false AND o.id NOT IN (SELECT productorder_id FROM receiptorders where deleted = false)")
		
		@officeexpenses_bon = Officeexpense.find_by_sql("SELECT o.* FROM officeexpenses o INNER JOIN officeexpensegroups g ON o.officeexpensegroup_id = g.id where o.date = '#{@date.to_date}' AND o.deleted = false AND g.officeexpensegroup_id = #{Officeexpensegroup.find_by_name('BON').id} AND o.id NOT IN (SELECT officeexpense_id FROM receiptexpenses where deleted = false)")
		@officeexpenses_office = Officeexpense.find_by_sql("SELECT o.* FROM officeexpenses o INNER JOIN officeexpensegroups g ON o.officeexpensegroup_id = g.id where o.date = '#{@date.to_date}' AND o.deleted = false AND g.officeexpensegroup_id = #{Officeexpensegroup.find_by_name('KANTOR').id} AND o.id NOT IN (SELECT officeexpense_id FROM receiptexpenses where deleted = false)")
		@officeexpenses_general = Officeexpense.find_by_sql("SELECT o.* FROM officeexpenses o INNER JOIN officeexpensegroups g ON o.officeexpensegroup_id = g.id where o.date = '#{@date.to_date}' AND o.deleted = false AND g.officeexpensegroup_id = #{Officeexpensegroup.find_by_name('UMUM').id} AND o.id NOT IN (SELECT officeexpense_id FROM receiptexpenses where deleted = false)")
		@officeexpenses_operational = Officeexpense.find_by_sql("SELECT o.* FROM officeexpenses o INNER JOIN officeexpensegroups g ON o.officeexpensegroup_id = g.id where o.date = '#{@date.to_date}' AND o.deleted = false AND g.officeexpensegroup_id = #{Officeexpensegroup.find_by_name('UMUM OPERASIONAL').id} AND o.id NOT IN (SELECT officeexpense_id FROM receiptexpenses where deleted = false)")
		@officeexpenses_stocks = Officeexpense.find_by_sql("SELECT o.* FROM officeexpenses o INNER JOIN officeexpensegroups g ON o.officeexpensegroup_id = g.id where o.date = '#{@date.to_date}' AND o.deleted = false AND g.id = #{Officeexpensegroup.find_by_name('UMUM').id} AND o.id NOT IN (SELECT officeexpense_id FROM receiptexpenses where deleted = false)")
		@officeexpenses_stnk = Officeexpense.find_by_sql("SELECT o.* FROM officeexpenses o INNER JOIN officeexpensegroups g ON o.officeexpensegroup_id = g.id where o.date = '#{@date.to_date}' AND o.deleted = false AND g.officeexpensegroup_id = #{Officeexpensegroup.find_by_name('Perpanjangan Pajak, STNK, KIR').id} AND o.id NOT IN (SELECT officeexpense_id FROM receiptexpenses where deleted = false)")
		@officeexpenses_docs = Officeexpense.find_by_sql("SELECT o.* FROM officeexpenses o INNER JOIN officeexpensegroups g ON o.officeexpensegroup_id = g.id where o.date = '#{@date.to_date}' AND o.deleted = false AND g.officeexpensegroup_id = #{Officeexpensegroup.find_by_name('DOKUMEN').id} AND o.id NOT IN (SELECT officeexpense_id FROM receiptexpenses where deleted = false)")
		@officeexpenses_incident = Officeexpense.find_by_sql("SELECT o.* FROM officeexpenses o INNER JOIN officeexpensegroups g ON o.officeexpensegroup_id = g.id where o.date = '#{@date.to_date}' AND o.deleted = false AND g.officeexpensegroup_id = #{Officeexpensegroup.find_by_name('Kecelakaan').id} AND o.id NOT IN (SELECT officeexpense_id FROM receiptexpenses where deleted = false)")
		@officeexpenses_fine = Officeexpense.find_by_sql("SELECT o.* FROM officeexpenses o INNER JOIN officeexpensegroups g ON o.officeexpensegroup_id = g.id where o.date = '#{@date.to_date}' AND o.deleted = false AND g.officeexpensegroup_id = #{Officeexpensegroup.find_by_name('Tilang').id} AND o.id NOT IN (SELECT officeexpense_id FROM receiptexpenses where deleted = false)")

		@payrolls = Payroll.find_by_sql("SELECT * FROM payrolls where date = '#{@date.to_date}' AND deleted = false AND id not in (SELECT payroll_id FROM receiptpayrolls where deleted = false)")
		@payrollreturns = Payrollreturn.find_by_sql("SELECT * FROM payrollreturns where date = '#{@date.to_date}' AND deleted = false AND payroll_id not in (SELECT payroll_id FROM receiptpayrollreturns where deleted = false)")

		@trainexpenses = Trainexpense.find_by_sql("SELECT * FROM trainexpenses where date = '#{@date.to_date}' AND deleted = false AND id not in (SELECT trainexpense_id FROM receipttrains where deleted = false)") 
		@shipexpenses = Shipexpense.find_by_sql("SELECT * FROM shipexpenses where date = '#{@date.to_date}' AND deleted = false AND id not in (SELECT shipexpense_id FROM receiptships where deleted = false)")
		@insuranceexpenses = Insuranceexpense.where("date = '#{@date.to_date}' AND deleted = false AND id not in (SELECT insuranceexpense_id FROM receiptinsurances where deleted = false)")
		
		@saldokas = Setting.find_by_name("Saldo Kas Kantor").value rescue nil || 0

    render :json => { :success => true,  :total => to_currency(@saldokas) ,:html => render_to_string(:partial => "cashiers/requests", :layout => false) }.to_json; 
	end
end