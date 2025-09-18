OfficePuraErp::Application.routes.draw do

  get "debug", to: "dashboards#debug"

  get 'approvals' => 'approvals#index'

  resources :legalities do
    member do
      get 'enable'
      get 'disable'
    end
  end

  devise_for :users,
    :controllers => { sessions: 'devise/sessions' },
    :path => "user",
    :path_names => {
      :sign_in => 'login',
      :sign_out => 'logout'
    }

  resources :routetrains do
    member do
      get 'enable'
      get 'disable'
    end
  end

  resources :routeships do
    member do
      get 'enable'
      get 'disable'
    end
  end

  resources :customers do
    member do
      get 'enable'
      get 'disable'
      get 'addroute'
      get 'addcontract'
      get 'clone'
      get 'gm_approve'
    end
    collection do
      get "customer_terms" => "customers#customer_terms"
    end
  end

  resources :customernotes, only: [:create, :update, :destroy]

  get 'contracts/addnew' => 'contracts#addnew'
  resources :contracts do
    member do
      get 'enable'
      get 'disable'
    end
  end

  resources :suppliers do
    member do
      get 'enable'
      get 'disable'
    end
  end

  resources :staffs do
    member do
      get 'enable'
      get 'disable'
    end
  end

  get 'drivers/blacklist' => 'drivers#blacklist'
  get 'drivers/history' => 'drivers#history'

  resources :drivers do
    member do
      get 'enable'
      get 'disable'
      get 'blacklisted'
      get 'whitelisted'
    end

    collection do
      get "create_bank_expense_group"
      get "clone"
      get "save_clone"
    end
  end
  
  get 'helpers/blacklist' => 'helpers#blacklist'
  resources :helpers do
    member do
      get 'enable'
      get 'disable'
    end

    collection do
      get "create_bank_expense_group"
    end
  end

  resources :isotanks do
    member do
      get 'enable'
      get 'disable'
    end
  end

  resources :containers do
    member do
      get 'enable'
      get 'disable'
    end
  end

  resources :operators do
    member do
      get 'enable'
      get 'disable'
    end
  end

  resources :products do
    member do
      get 'enable'
      get 'disable'
    end
  end

  resources :warehouses do
    member do
      get 'enable'
      get 'disable'
    end
  end

  resources :productgroups do
    member do
      get 'enable'
      get 'disable'
    end
  end

  get 'routes/addnew' => 'routes#addnew'
  resources :routes do
    member do
      get 'enable'
      get 'disable'
      get 'copy'
      get 'approve'
    end
    collection do
      get "index_api"
      get "index_api_detailed"
      get "managements"
    end
  end

  resources :claimmemos do
    member do
      get 'spv_approve'
      get 'load_approve'
      get 'unload_approve'
      get 'marketing_approve'
      get 'gm_approve'
    end
  end

  get 'quotationgroups/reports' => 'quotationgroups#reports'

  resources :quotationgroups do
    member do
      get "print"
      get "approve_customer"
      get "approve_sent"
      get "approve_confirm"
      get "approve_review"
    end
    collection do
      get 'confirmed' => 'quotationgroups#indexconfirm'
      get "getcustomer/:value" => 'quotationgroups#getcustomer'
      get "getquotation/:id" => 'quotationgroups#getquotation'
      get "index_api"
      get "indexconfirm_api"
      post "confirmation"
    end
  end

  get 'quotations/confirmed' => 'quotations#indexconfirm'
  resources :quotations do
    member do
      get 'enable'
      get 'disable'
      get "copy"
    end
    collection do
      get "index_api"
      get "indexconfirm_api"
      post "confirmation"
    end
  end
 
  match 'vehicles/index_asset' => 'vehicles#index_asset'
  post 'vehicles/update_asset' => 'vehicles#update_asset'
  get 'vehicles/history' => 'vehicles#history'

  resources :vehicles do
    member do
      get 'enable'
      get 'disable'
      get 'edit_asset'
    end
  end

  resources :vehiclelogs

  match 'vehiclelogs/new/:vehicle_id' => 'vehiclelogs#new'
  match "vehicledates" => "vehiclelogs#vehicledates"

  resources :vehiclegroups do
    member do
      get 'enable'
      get 'disable'
    end
  end

  resources :assets do
    member do
      get 'enable'
      get 'disable'
    end
  end

  resources :commodities do
    member do
      get 'enable'
      get 'disable'
    end
  end

  resources :assetgroups

  resources :allowances
  post 'allowances/updateitems' => 'allowances#updateitems'

  resources :tirebudgets
  post 'tirebudgets/updateitems' => 'tirebudgets#updateitems'

  resources :settings

  match 'generalexpenses/new(/:officeexpense_id)' => 'generalexpenses#new'
  post 'generalexpenses/create' => 'generalexpenses#create'
  resources :generalexpenses do
    member do
      get 'enable'
      get 'disable'
    end
  end

  get 'officeexpenses/getofficeexpensegroup/:group_id' => 'officeexpenses#getofficeexpensegroup'
  get 'officeexpenses/getbankexpensegroup/:bankgroup_id' => 'officeexpenses#getbankexpensegroup'

  get 'bankinvoices/getbankexpensegroup/:group_id' => 'bankinvoices#getbankexpensegroup'

  get 'bankexpenses/getbankexpensegroupdebit/:group_id' => 'bankexpenses#getbankexpensegroupdebit'
  get 'bankexpenses/getbankexpensegroupcredit/:group_id' => 'bankexpenses#getbankexpensegroupcredit'

  get 'events/get_event_by_customer/:customer_id' =>'events#get_event_by_customer'
  get 'events/getdodetail' => 'events#getdodetail'

  resources :mechaniclogs do
    member do
      get 'enable'
      get 'disable'
    end
  end

  resources :shipexpenses do
    member do
      get 'enable'
      get 'disable'
    end
  end

  resources :officeexpenses do
    member do
      get 'enable'
      get 'disable'
    end
  end

  resources :officebankexpenses

  resources :officeexpensegroups do
    member do
      get 'enable'
      get 'disable'
    end
  end

  resources :bankexpenses do
    member do
      get 'enable'
      get 'disable'
    end
  end

  resources :bankinvoices do
    member do
      get 'verified'
      get 'disable'
      get 'print'
    end
  end

  resources :bankexpensegroups do
    member do
      get 'enable'
      get 'disable'
      get 'inReportEnable'
      get 'inReportDisable'
    end
  end

  resources :offices do
    member do
      get 'enable'
      get 'disable'
    end
  end

  get 'invoices/printspk/:id' => 'invoices#printspk'

  match 'invoices/add_ship' => 'invoices#indexaddship'
  match 'invoices/add_ship/:invoice_id' => 'invoices#add_ship'
  post 'invoices/updateship/' => 'invoices#updateship'

  match 'invoices/add_train' => 'invoices#indexaddtrain'
  match 'invoices/add_train/:invoice_id' => 'invoices#add_train'
  post 'invoices/updatetrain/' => 'invoices#updatetrain'

  match 'invoices/add_weight' => 'invoices#indexaddweight'
  match 'invoices/add_weight/:invoice_id' => 'invoices#add_weight'
  post 'invoices/updateaddweight/' => 'invoices#updateaddweight'

  match 'invoices/updatedata/:invoice_id' => 'invoices#updatedata', as: 'updatedata'
  post 'invoices/updatedatabkk/' => 'invoices#updatedatabkk'

  #kosonganProduktif
  match 'invoices/kosongan_prod' => 'invoices#kosongan_prod'
  match 'invoices/add_kosongan' => 'invoices#add_kosongan'
  post 'invoices/createkosongan/' => 'invoices#createkosongan', as: 'createkosongan'

  #kosongan non Produktif
  match 'invoices/kosongan_approval' => 'invoices#kosongan_approval'
  match 'invoices/kosongan_approve(/:invoice_id)' => 'invoices#kosongan_approve'
  post 'invoices/kosongan_confirm/' => 'invoices#kosongan_confirm'

  match 'invoices/trainrequest' => 'invoices#indextrainrequest'

  match 'invoices/indexadd' => 'invoices#indexadd'
  match 'invoices/add(/:invoice_id)' => 'invoices#add'
  match 'invoices/indexinvoicetrain' => 'invoices#indexinvoicetrain'
  match 'invoices/adddriver(/:invoice_id)' => 'invoices#adddriver'
  post 'invoices/updateinvoice/' => 'invoices#updateinvoice'
  match 'invoices/print/:invoice_id' => 'invoices#print'
  match 'invoices/form_event' => 'invoices#form_event'
  match 'invoices/kosongan' => 'invoices#kosongan'

  match 'invoices/newupdated' => 'invoices#new_updated', as: "newupdate_invoice"
  match 'invoices/isotank' => 'invoices#isotank', as: "invoice_isotank"
  match 'invoices/kereta' => 'invoices#kereta', as: "invoice_train"
  match 'invoices/kapal' => 'invoices#kapal', as: "invoice_ship"
  match 'invoices/:invoice_id/editupdated' => 'invoices#edit_updated'

  resources :invoices do
    member do
      get 'enable'
      get 'disable'
      get 'step2'
      get 'confirmation'
      get 'printversion'
      get 'cancelmarketing'
    end

    collection do
      get "isotank"
    end
  end

  resources :invoicetrains

  resources :invoicetests do
    member do
      get 'enable'
      get 'disable'
      get 'step2'
      get 'confirmation'
      get 'printversion'
    end
  end

  resources :eventmemos do
    member do
      get 'enable'
      get 'disable'

      get "print"
    end
  end

  resources :eventcleaningmemos do
    member do
      get 'enable'
      get 'disable'
      get "print"
    end
  end

  resources :operators do
    member do
      get 'enable'
      get 'disable'
    end
  end

  resources :trainexpenses do
    collection do
      get 'download_excel'
    end
    member do
      get 'enable'
      get 'disable'
      get "print"
    end
  end

  resources :insurancevendors do
    member do
      get 'enable'
      get 'disable'
    end
  end

  resources :insuranceexpenses do
    member do
      get 'enable'
      get 'disable'
      get "print"
    end
  end

  match 'vendors/driver_activities' => 'vendors#driver_activities'

  resources :vendors do
    member do
      get 'enable'
      get 'disable'
    end
  end

  resources :vendorvehicles do
    member do
      get 'enable'
      get 'disable'
    end
  end

  get 'invoices/getcustomer/:office_id' => 'invoices#get_customer'
  get 'invoices/getvehiclegroup/:vehicle_id' => 'invoices#get_vehiclegroup'
  get 'invoices/getvehicles/:vehiclegroup_id' => 'invoices#get_vehicles'
  get 'invoices/getvehicle/:vehicle_id' => 'invoices#get_vehicle'
  get 'invoices/getvehiclesbyofficeid/:office_id' => 'invoices#get_vehicles_by_office_id'
  get 'invoices/gettanktype/:cargotype' => 'invoices#get_tanktype'

  get 'events/estimate_tonage/:price_per_type' => 'events#getestimatedtonage'

  get 'invoices/get_trainroute/:operator_id' => 'invoices#get_trainroute'
  get 'invoices/get_trainroute2/:operator_id' => 'invoices#get_trainroute2'
  get 'invoices/get_shiproute/:operator_id' => 'invoices#get_shiproute'
  get 'invoices/get_shiproute2/:operator_id' => 'invoices#get_shiproute2'
  get 'invoices/getroutesonly/:customer_id' => 'invoices#get_routesonly'

  get 'invoices/getroutes/:customer_id' => 'invoices#get_routes'
  get 'reports/getroutetrains/:operator_id' => 'reports#get_routetrains'
  get 'invoices/getroutesbyoffice/:office_id' => 'invoices#get_routesbyoffice'

  get 'invoices/getrouteswithtype/:customer_id/:transporttype' => 'invoices#get_routeswithtype'
  get 'invoices/getroutes2/:customer_id/:type' => 'invoices#get_routes2'
  get 'invoices/get_routesonly/:customer_id' => 'invoices#get_routesonly'
  get 'invoices/getdriverphone/:driver_id' => 'invoices#get_driverphone'


  get 'invoices/getallowances/:route_id/:vehicle_id/:trip/:quantity/:ishelper/:ispremi' => 'invoices#get_allowances'

  match 'invoicereturns/index_confirmed' => 'invoicereturns#index_confirmed'
  match 'invoicereturns/add/(:invoice_id)' => 'invoicereturns#add'
  match 'invoicereturns/train/(:invoice_id)' => 'invoicereturns#train'
  match 'invoicereturns/index_confirmedtrain' => 'invoicereturns#index_confirmedtrain'

  post 'invoicereturns/saveadd' => 'invoicereturns#saveadd'
  resources :invoicereturns

  match 'receiptorders/new/:productorder_id' => 'receiptorders#new'
  match 'receiptreturns/new/:invoicereturn_id' => 'receiptreturns#new'
  match 'receiptpremis/new/:invoice_id' => 'receiptpremis#new'
  match 'receiptexpenses/new/:officeexpense_id' => 'receiptexpenses#new'
  match 'receiptdrivers/new/:driverexpense_id' => 'receiptdrivers#new'
  match 'receiptincentives/new/:invoice_id' => 'receiptincentives#new'
  match 'driverexpenses/getdrivers/:type' => 'driverexpenses#getdrivers'

  get 'taxinvoiceitems/index-2' => 'taxinvoiceitems#index2'

  resources :receiptincentives
  resources :receiptpremis
  resources :receiptorders
  resources :receipts
  resources :receiptexpenses
  resources :receiptreturns
  resources :receiptdrivers
  resources :driverexpenses
  resources :taxinvoiceitems
  resources :users
  resources :driverlogs
  resources :supplierpayments
  resources :assetgroups
  resources :assetorders
  resources :taxgenericinvoices
  resources :ships
  resources :ports
  resources :receipttrains
  resources :receiptships
  resources :receiptinsurances

  resources :mechanics

  match 'assetpayments/new/:assetorder_id' => 'assetpayments#new'
  match 'assetpayments/index_confirmed' => 'assetpayments#index_confirmed'
  resources :assetpayments

  post 'taxinvoices/deletesentdatelog/:id' => 'taxinvoices#delete_sentdatelog'
  get 'taxinvoices/getsentdatelog/:taxinvoice_id' => 'taxinvoices#get_sentdatelog'
  get 'taxinvoices/gettaxinvoiceitems/:taxinvoice_id/:customer_id/:is_wholesale' => 'taxinvoices#gettaxinvoiceitems'
  match 'taxinvoices/downloadexcel/:taxinvoice_id' => 'taxinvoices#downloadexcel'
  post 'taxinvoices/updatepayment' => 'taxinvoices#updatepayment'
  post 'taxinvoices/transfer' => 'taxinvoices#transfer'

  post 'customers/transfer' => 'customers#transfer'

  resources :taxinvoices do
    member do
      get 'print'
      get 'printv2'
      get 'cancelpayment'
      get 'printreceipt'
      get 'clone'
      get 'updatecustomer'
    end
    collection do
      get 'downloadmultiexcel'
      post "update_tax"
      get 'generic-vehicles' => 'taxgenericinvoices#generic_vehicles'
      match 'generic/updateitems' => 'taxgenericinvoices#updateitems'
      match 'generic(/:id)' => 'taxgenericinvoices#new'
      get 'generic(/:id)/updatecustomer' => 'taxgenericinvoices#updatecustomer'

      match 'dp_only(/:id)' => 'taxinvoices#newdp'

      post 'updatecustomerinfo' => 'taxinvoices#updatecustomerinfo'
      post 'updatecustomerinfogeneric' => 'taxgenericinvoices#updatecustomerinfo'

      post 'updatepayment' => 'taxinvoices#updatepayment'
      post 'downpayment' => 'taxinvoices#downpayment'
      post 'canceldownpayment' => 'taxinvoices#canceldownpayment'

      post 'secondpayment' => 'taxinvoices#secondpayment'
      post 'cancelsecondpayment' => 'taxinvoices#cancelsecondpayment'

      post 'thirdpayment' => 'taxinvoices#thirdpayment'
      post 'cancelthirdpayment' => 'taxinvoices#cancelthirdpayment'

      post 'fourthpayment' => 'taxinvoices#fourthpayment'
      post 'cancelfourthpayment' => 'taxinvoices#cancelfourthpayment'

      post 'import_excel'
    end
  end

  resources :receipttaxinvitems do
    collection do
      get 'create_receiptinvoice'
      post 'create_receipt'
      post 'update_receipt'
    end
    member do
      get 'print'
      post 'confirm_billing'
      post 'update_printdate'
      get 'detail_excel'
    end
  end

  resources :taxinvoiceattachments
  get 'taxinvoiceattachments/gettaxinvoicesbycustomer/:customer_id' => 'taxinvoiceattachments#gettaxinvoicesbycustomer'

  match 'bonusreceipts/index_confirmed' => 'bonusreceipts#index_confirmed'

  resources :bonusreceipts do
    member do
      get 'confirmation'
    end
  end

  match 'incentives/index_confirmed' => 'incentives#index_confirmed'
  resources :incentives

  resources :productsales

  get 'sales/getpriceproductsale/:productsale_id' => 'sales#getpriceproductsale'

  resources :sales do
    member do
      get 'confirmation'
    end
  end

  match 'receiptsales/new/:sale_id' => 'receiptsales#new'
  resources :receiptsales

  get 'paymentchecks/new/:supplier_id' => 'paymentchecks#new'
  get 'paymentchecks/indexchecks' => 'paymentchecks#indexchecks'
  resources :paymentchecks

  get 'cashiers/getrequests(/:date)' => 'cashiers#getrequests'
  resources :cashiers

  match 'events/add_dovendor' => 'events#indexadddovendor'
  match 'events/add_dovendor/:event_id' => 'events#add_dovendor'
  match 'events/getdovendor'
  match 'events/getdovroutes/:customer_id' => 'events#getdovroutes'
  match 'events/getdovvendors/:multimoda' => 'events#getdovvendors'
  match 'events/getdovvendorroutes/:vendor_id' => 'events#getdovvendorroutes'
  match 'events/transferdov' => 'events#transferdov'

  get 'events/geteventsv2(/:type)' => 'events#geteventsv2'
  get 'events/getevents(/:type)' => 'events#getevents'

  match 'events/version-2' => 'events#version2'
  get 'events/resync' => 'events#resync'
  get 'events/cancelled' => 'events#cancelled'
  get 'events/get_unpaid_inv' => 'events#get_unpaid_inv'

  match 'events/remove' => 'events#remove'

  resources :events do
    member do
      get 'restore'
    end
    collection do
      get 'getdovendor' => 'events#getdovendor'
    end
  end

  get 'bookings/getbookings(/:type)' => 'bookings#getbookings'
  get 'bookings/report-bookings' => 'bookings#report_bookings'
  resources :bookings

  get 'productrequests/getproductstocks/:product_id' => 'productrequests#getproductstocks'
  get 'productrequests/getrangetires/:productgroup_id/:vehicle_id/:date' => 'productrequests#getrangetires'
  get 'productrequests/getproductbygroupid/:productgroup_id' => 'productrequests#getproductbygroupid'
  get 'productrequests/getproductgroupname/:productgroup_id' => 'productrequests#getproductgroupname'

  resources :productrequests do
    member do
      get 'confirmation'
    end
  end

  match 'productorders/add/' => 'productorders#add'
  get 'productorders/getproductbyid/:product_id' => 'productorders#getproductbyid'
  post 'productorders/updateitem/' => 'productorders#updateitem'
  resources :productorders do
    member do
      get 'confirmation'
      get 'return'
    end
  end

    match 'receipts/new/:invoice_id' => 'receipts#new'
    match 'invoicereturns/new/:invoice_id' => 'invoicereturns#new'
    match 'taxinvoiceitems/new/:invoice_id(/:update)' => 'taxinvoiceitems#new'
    match 'taxinvoiceitems/print(/:invoice_id)' => 'taxinvoiceitems#print'
    post 'taxinvoiceitems/updateitems' => 'taxinvoiceitems#updateitems'
    post 'taxinvoiceitems/rejected' => 'taxinvoiceitems#rejected'
    get 'taxinvoiceitems/getCustomerbyDate/:date' => 'taxinvoiceitems#getCustomerbyDate'
    get 'taxinvoiceitems/vendor_detail/:item_id' => 'taxinvoiceitems#vendor_detail'
    match 'taxinvoices/new(/:customer_id)' => 'taxinvoices#new'
    match 'taxinvoices/updateitems' => 'taxinvoices#updateitems'
    match 'taxinvoices/payment/:taxinvoice_id' => 'taxinvoices#payment'
    match 'taxinvoices/send_email/:taxinvoice_id' => 'taxinvoices#send_email'
    match 'driverlogs/new/:driver_id' => 'driverlogs#new'

  match 'bonusreceipts/new/:invoice_id' => 'bonusreceipts#new'
  post 'bonusreceipts/updateitems' => 'bonusreceipts#updateitems'
  match 'incentives/new/:invoice_id' => 'incentives#new'
  post 'incentives/updateitems' => 'incentives#updateitems'

  match "masters" => "customers#index"
  match "transactions" => "invoices#index"
  match "reports" => "reports#index"

  match "login" => "application#login", :as => :login_cms
  match "logout" => "application#logout", :as => :logout_cms
  match "notauthorized" => "application#notauthorized"

  match "settings" => "settings#index"

  scope "dashboards" do
    match "incomes-vehicle" => 'dashboards#incomes_vehicle'
    match "expenses-vehicle" => 'dashboards#expenses_vehicle'
    match 'getincomevehicledata/:year' => 'dashboards#getincomevehicledata'
    match 'getexpensevehicledata/:year' => 'dashboards#getexpensevehicledata'
  end

  match "dashboard" => 'dashboards#dashboard_layout'

  resources :dashboards
  
  get "marketings" => 'marketings#index'
  get "marketings/filtered" => 'marketings#filtered'
  get "marketings/estimations" => 'marketings#estimations'
  get "marketings/getomzetdata" => 'marketings#getomzetdata'
  get "marketings/getomzetdatamarketing" => 'marketings#getomzetdatamarketing'

  get "reports/getomzetbillings" => 'reports#getomzetbillings'

  scope "reports" do
    match "taxinvoices_report" => 'reports#taxinvoices_report'
    match "taxinvoiceitems_report" => 'reports#taxinvoiceitems_report'
    match "taxinvoiceitems_upload_report" => 'reports#taxinvoiceitems_upload_report'
    match "isotanks_report" => 'reports#isotanks_report'
    match "containers_report" => 'reports#containers_report'

    match "annualreport_vehicle/:vehicle_id/:year" => 'reports#annualreport_vehicle'
    match "incomes-statement" => 'reports#incomes_statement'
    match "incomes-cashinout" => 'reports#incomes_cashinout'
    match "incomes-statement-nocharge" => 'reports#incomes_statement_nocharge'
    match "incomes-cashinout" => 'reports#incomes_cashinout'
    match "incomes-cashinoutdetail/:year/:month" => 'reports#incomes_cashinoutdetail', :as => :incomes_cashinoutdetail

    match "expenses-bank" => 'reports#expenses_bank'
    match "expenses-office" => 'reports#expenses_office'
    match "productstocks" => 'reports#productstocks'
    match "paymentchecks" => 'reports#paymentchecks'
    match "expenses-daily" => 'reports#expenses_daily'
    #match "expenses-daily-temp" => 'reports#expenses_daily_temp'
    match "expenses-daily-new" => 'reports#expenses_daily_new'
    match "expenses-gas" => 'reports#expenses_gas'
    match "expenses-vehicle" => 'reports#expenses_vehicle'
    match "expenses-drivers" => 'reports#expenses_drivers'
    match "incomes-vehicle" => 'reports#incomes_vehicle'
    match "product-orders" => 'reports#product_orders'
    match "invoices" => 'reports#invoices', :as => :report_invoices
    match "gas-vouchers" => 'reports#gas_vouchers'
    match "gas-leftovers" => 'reports#gas_leftovers'
    match "customers" => 'reports#customers'
    match "customercredits" => 'reports#customercredits'
    match "suppliercredits" => 'reports#suppliercredits'
    match "tiretargets" => 'reports#tiretargets'
    match "getcustomerdata/:year" => 'reports#getcustomerdata'
    match "assets" => 'reports#assets'
    match "suppliers" => 'reports#suppliers'
    match "estimation" => 'reports#estimation'
    match "downloadexcelexpensedaily/:date" => 'reports#downloadexcelexpensedaily'
    match "getannualreportvehicle/:vehicle_id" => 'reports#getannualreportvehicle'
    match "sales" => 'reports#sales'
    match "expensesdriverdaily" => 'reports#expensesdriverdaily'
    match "payroll" => 'reports#payroll',  :as => :report_payrolls
    match "bonus-receipts" => 'reports#bonus_receipts'
    match "downloadexcelpayroll/:date" => 'reports#downloadexcelpayroll'
    match "filterledger" => 'reports#filterledger'
    match "ledger" => 'reports#ledger'
    match "balances" => 'reports#balances'
    match "invoicereturns" => 'reports#invoicereturns'
    match "taxinvoiceitems" => 'reports#taxinvoiceitems', :as => :report_taxinvoiceitems
    match "downloadexcelproductstocks" => 'reports#downloadexcelproductstocks'
    match "downloadexcelproductorder/:startdate&:enddate" => 'reports#downloadexcelproductorder'

    match 'estimation-income-expense' => 'reports#estimationincomeexpense'
    match 'estimationdashboard' => 'reports#estimationdashboard'
    match 'revenue-breakdown' => 'reports#revenuebreakdown'
    match 'estimation-event-expense' => 'reports#estimation_event_expense'
    match 'estimation-event-expense-cancelled' => 'reports#estimation_event_expense_cancelled'

    match 'branches' => 'reports#branches'
    match 'branches-stats' => 'reports#branches_stats'
    match 'getbranchstats' => 'reports#apibranchstats'
    match 'getbranchstatsbkk' => 'reports#apibranchstatsbkk'
    match 'getbranchstatsbkkbreakdown' => 'reports#apibranchstatsbkkbreakdown'

    match 'getbranchstatsincidents' => 'reports#apibranchstatsincidents'

    get 'billings-stats' => 'reports#billings_stats'

    match 'shrinkreport' => 'reports#shrinkreport'
    get "driver-rit" => 'reports#driver_rit'
    get 'unpaid_invoice' => 'reports#unpaid_invoice'
    get 'paid_invoice' => 'reports#paid_invoice'

    get "confirmed-invoices" => 'reports#confirmed_invoices'
    get "confirmed-latest-invoices" => 'reports#confirmed_latest_invoices'
    get "collectible-invoices" => 'reports#collectible_invoices'

    get "isotanks-utilization" => 'reports#isotankutilization'
    get "containers-utilization" => 'reports#containerutilization'

    get "memocleanings" => 'reports#memocleanings'

    #AR new modules
    get "ar_aging" => "reports#ar_aging"
    get "cashins" => "reports#cashins"
    get "doubtful_ar_reports" => "summaries#doubtful_ar_reports"

    # match "indexannualreport_vehicle" => 'reports#indexannualreport_vehicle'
    get "indexannualreport_vehicle" => "reports#indexmonthlyreport_vehicle"
    match "indexannualreport_vehicle2" => 'reports#indexannualreport_vehicle'
    match "incomeexpenseestimation_vehicle" => 'reports#incomeexpenseestimation_vehicle'
    match "drivervehicles" => 'reports#drivervehicles', :as => :report_drivervehicles
  end

  match 'payrolls/getdrivers/:type' => 'payrolls#getdrivers'
  match 'payrolls/getdriverdata/:type/:id' => 'payrolls#getdriverdata'

  resources :payrolls do
    member do
      get 'confirmation'
    end
  end

  match 'payrollreturns/index_confirmed' => 'payrollreturns#index_confirmed'
  match 'payrollreturns/new/:payroll_id' => 'payrollreturns#new'
  resources :payrollreturns

  match 'receiptpayrolls/new/:payroll_id' => 'receiptpayrolls#new'
  resources :receiptpayrolls

  match 'receiptpayrollreturns/new/:payrollreturn_id' => 'receiptpayrollreturns#new'
  resources :receiptpayrollreturns

  match 'docs(/:gkey/:sheetname)' => 'googledocs#index'

  match '/media/:dragonfly/:file_name', :to => Dragonfly[:images]
  post 'attachments/upload' => 'attachments#upload', :as => :attachments_upload
	post 'attachments/uploadTaxInv' => 'attachments#uploadTaxInv', :as => :attachments_uploadTaxInv
  post 'attachments/uploadQuot' => 'attachments#uploadQuot', :as => :attachments_uploadQuot

  get 'attachments/remove/:id' => 'attachments#remove', :as => :attachments_remove
	get 'attachments/removeTaxInv/:id' => 'attachments#removeTaxInv', :as => :attachments_removeTaxInv
	get 'attachments/removeQuot/:id' => 'attachments#removeQuot', :as => :attachments_removeQuot




  match 'deletes/action' => 'deletes#action'
  match 'deletes/money' => 'deletes#money'
  match 'deletes/bankexpense' => 'deletes#bankexpense'
  match 'deletes/receiptreturn' => 'deletes#receiptreturn'
  match 'deletes/trainexpense' => 'deletes#trainexpense'
  match 'deletes/insuranceexpense' => 'deletes#insuranceexpense'

  resources :containermemos do
    member do
      get 'enable'
      get 'disable'
    end
  end

	match "helpdesks" => "helpdesks#index"
  match "search" => "helpdesks#search"
  match "searchevents" => "helpdesks#searchevents"

	match "helpdesks/edit/:id" => "helpdesks#edit"
	match "helpdesks/show/:id" => "helpdesks#show"
	match "helpdesks/new" => "helpdesks#new"
	post "helpdesks/create" => "helpdesks#create"
 	post 'helpdesks/updateticket'=> 'helpdesks#updateticket'

	get 'api/vehiclesapi' => 'vehiclesapi#index'
	get 'api/vehiclesapi/detail/:id' => 'vehiclesapi#detail'
	get 'api/vehiclesapi/search' => 'vehiclesapi#search'
	put 'api/vehiclesapi/update/:id' => 'vehiclesapi#update'
	put 'api/vehiclesapi/createlogs/:id' => 'vehiclesapi#createlogs'
	get 'api/vehiclesapi/list' => 'vehiclesapi#vehicleFormList'
	get 'api/vehiclesapi/current_bkk' => 'vehiclesapi#current_bkk'
	get 'api/vehiclesapi/vehicle_invoice_list' => 'vehiclesapi#vehicle_invoice_list'

  get 'api/get_container_pura' => 'containers#get_container_pura'
  get 'api/containersapi/get_container_pura' => 'containersapi#get_container_pura'

    get 'api/driversapi' => 'driversapi#index'
    get 'api/driversapi/detail/:id' => 'driversapi#detail'
    get 'api/driversapi/search' => 'driversapi#search'
    get 'api/driversapi/login' => 'driversapi#login'
    put 'api/driversapi/update/:id' => 'driversapi#update'
    put 'api/driversapi/createlogs/:id' => 'driversapi#createlogs'
    get 'api/driversapi/activeinvoice/:id' => 'driversapi#activeInvoice'
    get 'api/driversapi/invoicesj/:id' => 'driversapi#invoiceSJ'
    get 'api/driversapi/invoicehistory/:id' => 'driversapi#history'
    get 'api/driversapi/list' => 'driversapi#driverFormList'
    get 'api/driversapi/getdriver_by_idcard' => 'driversapi#getdriver_by_idcard'

    get 'api/dashboard' => 'dashboards#widget'

    get 'api/report/annualvehicle' => 'reportsapi#annualvehicle'
    get 'api/report/get_today_invoice' => 'reportsapi#get_today_invoice'
    get 'api/report/vehicledetails' => 'reportsapi#vehicle_details'

    get 'api/customer/customerroutes' => 'reportsapi#customer_routes'

    get 'taxinvoiceitems/downloadexcel/:id', to: 'taxinvoiceitems#downloadexcel'

    get 'report-events' => 'events#report_events'
    get 'report-dp-events' => 'events#report_dpevents'
    get 'report-events-summary' => 'events#event_summary'

    get 'report-invoices-summary' => 'invoices#invoice_summary'

    get 'api/login' => 'auth#login'
    get 'api/invoices' => 'invoicesapi#index'
    get 'api/invoices/confirmed' => 'invoicesapi#confirmed'
    get 'api/invoices/getapi_invoices' => 'invoicesapi#getapi_invoices'
    get 'api/invoices/detail/:id' => 'invoicesapi#detail'
    get 'api/taxinvoices/duedate' => 'taxinvoicesapi#index'

    post 'api/attachments/uploadtaxinvoice' => 'attachmentapi#uploadTaxInv'
    post 'api/attachments/remove/:id' => 'attachmentapi#remove'

    post 'taxinvoiceitemvs/api/post-taxinvoiceitemv' => 'taxinvoiceitemv#postapi_taxinvoiceitemv'
    post 'api/taxinvoiceitems/create' => 'taxinvoiceitemapi#updateitems'
    get 'api/taxinvoiceitems/detail/:id' => 'taxinvoiceitemapi#detail'

    match 'trainexpenses-paid' => 'trainexpenses#paid'
    match 'trainexpenses/new/:invoice_id' => 'trainexpenses#new'
    match 'trainexpenses/delete/:invoice_id' => 'trainexpenses#delete'

    match 'shipexpenses-paid' => 'shipexpenses#paid'
    match 'shipexpenses/new/:invoice_id' => 'shipexpenses#new'
    match 'shipexpenses/delete/:invoice_id' => 'shipexpenses#delete'

    match 'insuranceexpenses-paid' => 'insuranceexpenses#paid'
    match 'insuranceexpenses/new/:invoice_id' => 'insuranceexpenses#new'
    match 'insuranceexpenses/delete/:invoice_id' => 'insuranceexpenses#delete'

    match 'receipttrains/new/:trainexpense_id' => 'receipttrains#new'
    match 'receiptships/new/:shipexpense_id' => 'receiptships#new'
    match 'receiptinsurances/new/:insuranceexpense_id' => 'receiptinsurances#new'

    match 'mechaniclogs-done' => 'mechaniclogs#done'
    match 'mechaniclogs/new/:invoice_id' => 'mechaniclogs#new'
    match 'mechaniclogs/delete/:invoice_id' => 'mechaniclogs#delete'
    get 'mechaniclogs-proceed' => 'mechaniclogs#proceed'
    get 'mechaniclogs-maintenance' => 'mechaniclogs#maintenance'

    scope "monitoring" do
      match "operational" => 'monitorings#operational'
    end

    scope "api" do
      scope "invoices", controller: "invoicesapi" do
        post 'create_invoice' => 'invoicesapi#createInvoice'
        get "get_vehicles_by_office_id"
        get "check_tanktype"
        get "get_routes"
        get "get_office_tanktype_and_customer"
      end
    end

    post 'api/routelocations/create/:route_id' => 'routelocations#createApi'
    get 'api/routelocations/:route_id' => 'routelocations#getDataApi'
    match 'routelocations/new/:route_id' => 'routelocations#new'
    match 'routelocations/edit/:route_id' => 'routelocations#edit'
    get 'routelocations/checkDistance' => 'routelocations#checkDistance'

    resources :routelocations do
      member do
        get 'enable'
        get 'disable'
      end
    end

    resources :recapinvoicebyroutes do
      collection do
        get 'excelbyroutes'
      end
    end

    scope "api_customers", controller: "api/api_customers" do
      get "get_all_customers"
      get "get_detail_customer"
    end

    scope "api_taxinvoices", controller: "api/api_taxinvoices" do
      get "get_detail_taxinvoice"
      post "create_taxinvoice"
      post "create_taxinvoice_2"
      post "create_taxinvoice_taxgenericitem"
      post "create_taxinvoice_taxgenericitem_2"
    end

    scope "api_routes", controller: "api/api_routes" do
      get "get_detail_route"
      post "create_route"
      post "create_route_2"
      post "create_allowance"
      post "create_allowance_2"
    end

    root :to => 'application#home'
end
