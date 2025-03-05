var applet = null;

Number.prototype.formatMoney = function(c, d, t){
var n = this, c = isNaN(c = Math.abs(c)) ? 2 : c, d = d == undefined ? "," : d, t = t == undefined ? "." : t, s = n < 0 ? "-" : "", i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "", j = (j = i.length) > 3 ? j % 3 : 0;
   return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
 };

function jZebra() {
	$('#appletContainer').html('<applet name="jzebra" code="jzebra.PrintApplet.class" archive="/assets/jzebra.jar" width="1" height="1"><param name="cache_option" value="plugin"><param name="cache_archive" value="/assets/jzebra.jar"><param name="cache_version" value="1.4.8.0"></applet>');
}

function zebraprint(name) {	
	if (applet != null) {

		if (name == 'invoice') {
			applet.append(chr(27) + chr(64));
			applet.append(chr(27) + chr(67) + chr(0) + chr(54));
			applet.append("\n"+ $("#strClientName").html() +"\n");
			applet.append("BUKTI KAS KELUAR "+ $("#strInvoiceId").val() + "\n");
			applet.append("===================================\n");
			applet.append("Tanggal     "+ $("#strDate").html()+"\n");
			applet.append("Kantor     "+ $("#strOffice").html()+"\n");
			applet.append("Pelanggan   "+ $("#strCustomer").html()+"\n");
			if($("#strRoute").html().length > 23)
			{
				arr = split_chars_words($("#strRoute").html() ,23);
				applet.append("Jurusan     "+ arr[0] +"\n");
				applet.append("            "+ arr[1] +"\n");
			}else{
				applet.append("Jurusan     "+ $("#strRoute").html()+"\n");
			}
			applet.append("Jumlah      "+ $("#strQty").html()+" Rit\n");
			applet.append("Tipe        "+ $("#strType").html()+"\n");
			applet.append("Kendaraan   "+ $("#strVehicle").val()+"\n");
            if($("#strIsotank").html().length > 0)
            {
            applet.append("No. Isotank     "+ $("#strIsotank").html()+"\n");
            }
            if($("#strIsotank2").html().length > 0)
            {
            applet.append("No. Isotank     "+ $("#strIsotank2").html()+"\n");
            }
            if($("#strContainer").html().length > 0)
            {
            applet.append("No. Kontainer     "+ $("#strContainer").html()+"\n");
            }
            if($("#strContainer2").html().length > 0)
            {
            applet.append("No. Kontainer     "+ $("#strContainer2").html()+"\n");
            }
			applet.append("Supir       "+ $("#strDriver").val()+"\n");
			if($('#strDescription').length > 0){
			applet.append("Keterangan  \n")
				if($("#strDescription").html().length > 35)
				{
					arr = split_chars_space($("#strDescription").html() ,35);
					applet.append(arr[0] + "\n");
					applet.append(arr[1] + "\n");
				}else{
					applet.append($("#strDescription").html()+"\n");
				} 
			}
			applet.append("-----------------------------------\n")
			applet.append("UM Supir    Rp. "+ $("#invoice_driver_allowance").val()+",00\n");
			applet.append("UM Kernet   Rp. "+ $("#invoice_helper_allowance").val()+",00\n");
			applet.append("Lain-lain   Rp. "+ $("#invoice_misc_allowance").val()+",00\n");
			applet.append("Solar       Rp. "+ $("#invoice_gas_allowance").val()+",00\n");
			applet.append("ASDP        Rp. "+ $("#invoice_ferry_fee").val()+",00\n");
			applet.append("Tol         Rp. "+ $("#invoice_tol_fee").val()+",00\n");
            applet.append("Premi       Rp. "+ $("#invoice_premi_allowance").val()+",00\n");
			applet.append("-----------------------------------\n");
			applet.append("Total       Rp. "+ $("#invoice_total").val()+",00" + "\n");
			applet.append("-----------------------------------\n");
			if($("#strFooter").html().length > 35)
			{
				arr = split_chars_space($("#strFooter").html() ,35);
				applet.append(arr[0] + "\n");
				applet.append(arr[1] + "\n");
			}else{
				applet.append($("#strFooter").html()+"\n");
			}
			applet.append("\nDibuat oleh " + $("#strCreator").html()+"\n");
			applet.print();

		} else if (name == 'incentive') {
			applet.append(chr(27) + chr(64));
			applet.append(chr(27) + chr(67) + chr(0) + chr(54));
			applet.append("\n"+ $("#strClientName").html() +"\n");
			applet.append("BUKTI KAS INSENTIF "+ $("#strIncentiveId").val() + "\n");
			applet.append("===================================\n");
			applet.append("BKK         "+ $("#strInvoiceId").html()+"\n");
			applet.append("Kendaraan   "+ $("#strVehicle").html()+"\n");
			applet.append("Supir       "+ $("#strDriver").val()+"\n");
			if($("#strRoute").html().length > 23)
			{
				arr = split_chars_words($("#strRoute").html() ,23);
				applet.append("Jurusan     "+ arr[0] +"\n");
				applet.append("            "+ arr[1] +"\n");
			}else{
				applet.append("Jurusan     "+ $("#strRoute").html()+"\n");
			}
			applet.append("Konfirmasi  "+ $("#strCreatedDate").html()+"\n");
			applet.append("Total Insentif "+ $("#strTotalIncentive").html()+"\n");

			if($('#strDescription').length > 0){
			applet.append("\nKeterangan  \n")
				if($("#strDescription").html().length > 35)
				{
					arr = split_chars_space($("#strDescription").html() ,35);
					applet.append(arr[0] + "\n");
					applet.append(arr[1] + "\n");
				}else{
					applet.append($("#strDescription").html()+"\n");
				}
			}
			applet.append("\nDibuat oleh " + $("#strCreator").html()+"\n");
			applet.append("\n\n");

			applet.print();

		} else if (name == 'premi') {
			applet.append(chr(27) + chr(64));
			applet.append(chr(27) + chr(67) + chr(0) + chr(54));
			applet.append("\n"+ $("#strClientName").html() +"\n");
			applet.append("BUKTI KAS PREMI "+ $("#strPremiId").val() + "\n");
			applet.append("===================================\n");
			applet.append("BKK         "+ $("#strInvoiceId").html()+"\n");
			applet.append("Kendaraan   "+ $("#strVehicle").html()+"\n");
			applet.append("Supir       "+ $("#strDriver").val()+"\n");
			if($("#strRoute").html().length > 23)
			{
				arr = split_chars_words($("#strRoute").html() ,23);
				applet.append("Jurusan     "+ arr[0] +"\n");
				applet.append("            "+ arr[1] +"\n");
			}else{
				applet.append("Jurusan     "+ $("#strRoute").html()+"\n");
			}
			applet.append("Konfirmasi  "+ $("#strCreatedDate").html()+"\n");
			applet.append("Total Premi "+ $("#strTotalPremi").html()+"\n");

			applet.append("\nPemuatan    \n");
			applet.append("Lokasi      "+ $("#strLoadLocation").html()+"\n");
			applet.append("Tanggal     "+ $("#strLoadDate").html()+"\n");
			applet.append("Jam         "+ $("#strLoadHour").html()+"\n");
			
			applet.append("\nBongkar    \n");
			applet.append("Lokasi      "+ $("#strUnloadLocation").html()+"\n");
			applet.append("Tanggal     "+ $("#strUnloadDate").html()+"\n");
			applet.append("Jam         "+ $("#strUnloadHour").html()+"\n");

			if($('#strDescription').length > 0){
			applet.append("\nKeterangan  \n")
				if($("#strDescription").html().length > 35)
				{
					arr = split_chars_space($("#strDescription").html() ,35);
					applet.append(arr[0] + "\n");
					applet.append(arr[1] + "\n");
				}else{
					applet.append($("#strDescription").html()+"\n");
				}
			}
			applet.append("\nDibuat oleh " + $("#strCreator").html()+"\n");
			applet.append("\n\n");

			applet.print();
		} else if (name == 'order') {
			applet.append(chr(27) + chr(64));
			applet.append(chr(27) + chr(67) + chr(0) + chr(54));
			applet.append("\n"+ $("#strClientName").html() +"\n");
			applet.append("ORDER PEMBELIAN "+ $("#strOrderId").val() + "\n");
			applet.append("===============================================================================\n");
			applet.append("Tanggal     "+ $("#strDate").html()+"\n");
			applet.append("Keterangan  "+ $("#strDescription").html()+"\n");
			applet.append("-------------------------------------------------------------------------------\n");
			applet.append(align_left("NO.", 4));
			applet.append(align_left("NAMA BARANG", 41));
			applet.append(align_center("JUMLAH", 10));
			applet.append(align_right("HARGA", 10));
			applet.append(align_right("TOTAL", 14) +"\n");
			applet.append("-------------------------------------------------------------------------------\n");

			index = 1;
			$('#tableorder tr').each(function(){
				id = $(this).attr("id");

				if(parseInt(id) > 0){

					if (index == 10){
						applet.append("\n\n\n\n\n\n");
					}
					applet.append(align_left(index.toString() +".", 4));
					applet.append(align_left($('#productname_'+id).html() + " " + $('#bon_'+id).val(), 41));
					applet.append(align_center($('#quantity_'+id).html(), 10));
					applet.append(align_right($('#price_'+id).html(), 10));
					applet.append(align_right($('#total_'+id).html(), 14) +"\n");
	 				applet.append(align_left(print_whitespace(4) + $('#supplier_'+id).val(), 41) +"\n");
					index++;
				}
			});

			applet.append("-------------------------------------------------------------------------------\n");
			applet.append(print_whitespace(55) + align_right("TOTAL", 10) + align_right($("#strTotal").html(),14) + "\n");
			applet.append("-------------------------------------------------------------------------------\n");
		    applet.append("\nDibuat oleh " + $("#strCreator").html()+"\n");
			var i = 0;
			if(index < 10){
				for(i=index; i<9; i++)
				{
					applet.append("\n\n");
				}
				
				applet.append("\n\n\n\n");
			}else{
				for(i=0; i<9; i++)
				{
					applet.append("\n\n");
				}
				applet.append("\n\n\n\n\n\n");
			}

		    applet.print();
		} else if(name == 'payroll'){
			applet.append(chr(27) + chr(64));
			applet.append(chr(27) + chr(67) + chr(0) + chr(54));
			applet.append("\n"+ $("#strClientName").html() +"\n");
			applet.append("SLIP GAJI "+ $("#strPayrollId").val() + "\n");
			applet.append("===============================================================================\n");
			applet.append("Tanggal     "+ $("#strDate").html()+"\n");
			applet.append("Period      "+ $("#strPeriod").html()+"\n");
			
			if($('#strDriver').html().length > 0)
			{
				applet.append("Supir       "+ $("#strDriver").html()+"\n");
			}else
			{
				applet.append("Kernet      "+ $("#strHelper").html()+"\n");
			}
			applet.append("-------------------------------------------------------------------------------\n");
			applet.append("PENERIMAAN" + "\n");
			applet.append(align_left("Non HLN",18) + ": " + align_right($('#lblNonHolidays').html(),12) + " x " + align_right($('#lblNonHolidaysFare').html(), 12) +" = " + align_right($('#lblNonHolidaysPayment').html(), 12) +"\n");
			applet.append(align_left("HLN",18) + ": " + align_right($('#lblHolidays').html(),12) + " x " + align_right($('#lblHolidaysFare').html(), 12) +" = " + align_right($('#lblHolidaysPayment').html(), 12) +"\n");
			applet.append(align_left("Ambil Tabungan",18) + ": " + print_whitespace(27) + " = " + align_right($('#lblSavingReduction').html(), 12) +"\n");
			applet.append(align_left("Premi Hadir",18) + ": " + print_whitespace(27) + " = " + align_right($('#lblBonus').html(), 12) +"\n");
			applet.append(align_left("TOTAL",50) +  align_right($('#lblTotalPayment').html(), 12) +"\n\n");
			applet.append("Revisi Tabungan (" + $('#lblMasterSaving').html() + " - " + $('#lblSavingReduction2').html() + " = " + $('#lblSavingRed').html() +")" +"\n\n");

			applet.append(align_left("POTONGAN",20) + align_right("JML", 12) + print_whitespace(3) + align_right("POT",12) + print_whitespace(3) + align_right("SISA",12) +"\n");
			applet.append(align_left("Klaim Susut",18) + ": " + align_right($('#lblMasterWeightLoss').html(), 12) + print_whitespace(3) + align_right($('#lblPayrollWeightLoss').html(),12) + print_whitespace(3) + align_right($('#lblTotalWeightLoss').html(),12) +"\n");
			applet.append(align_left("Klaim Kecelakaan",18) + ": " + align_right($('#lblMasterAccident').html(), 12) + print_whitespace(3) + align_right($('#lblPayrollAccident').html(),12) + print_whitespace(3) + align_right($('#lblTotalAccident').html(),12) +"\n");
			applet.append(align_left("Klaim Onderdil",18) + ": " + align_right($('#lblMasterSparepart').html(), 12) + print_whitespace(3) + align_right($('#lblPayrollSparepart').html(),12) + print_whitespace(3) + align_right($('#lblTotalSparepart').html(),12) +"\n");
			applet.append(align_left("Pinjaman",18) + ": " + align_right($('#lblMasterBon').html(), 12) + print_whitespace(3) + align_right($('#lblPayrollBon').html(),12) + print_whitespace(3) + align_right($('#lblTotalBon').html(),12) +"\n");
			applet.append(align_left("Gantungan Sangu",18) + ": " + align_right("-", 12) + print_whitespace(3) + align_right($('#lblPayrollAllowance').html(),12) + print_whitespace(3) + align_right("-",12) +"\n");
			applet.append(align_left("Menabung",18) + ": " + align_right($('#lblSavingRed2').html(), 12) + print_whitespace(3) + align_right($('#lblPayrollSaving').html(),12) + print_whitespace(3) + align_right($('#lblTotalSaving').html(),12) +"\n");
			applet.append(align_left("TOTAL",18) + print_whitespace(17) + align_right($('#lblPayrollExpenseTotal').html(),12) + print_whitespace(15) +"\n\n");
			applet.append(align_left("DITERIMA",18) + print_whitespace(30) + "Rp. "+ align_right($('#lblPayrollTotal').html(),10) +"\n");

			applet.append("\nDibuat oleh " + $("#strCreator").html()+"\n");
			applet.print();
		}
	} else {
		window.print();
	}
}

function print_receipttaxinvitem () {
	id = $('#receipt_id').val();
	printdate = $('#printdate').val();

	if (printdate == "") {
		$.ajax({
			type: "POST",
			url: "/receipttaxinvitems/" + id + "/update_printdate",
			success: function(data) {
				var date = new Date(data.printdate);
				var stringdate = ("0" + date.getDate()).slice(-2) + "-" + ("0"+(date.getMonth()+1)).slice(-2) + "-" + date.getFullYear();
				$('#printdate').val(stringdate);
				$('#printdate_label').text("Tanggal : " + stringdate);
				window.print();		
			},
			failure: function() {
				alert("Error. Mohon refresh browser Anda.");
			}
		});
	} else {
		window.print();
	}
}

function chr(i) {
  return String.fromCharCode(i);
} 

function split_chars_space(text, len)
{
	arr = text.split(" ");
	var objRet = new Array(2);
	objRet[0] = "";
	objRet[1] = "";

	for(i=0;i<arr.length;i++){
		if(objRet[0].length + arr[i].length > len)
		{
			objRet[1] += arr[i] + " ";
		}
		else
		{
			objRet[0] += arr[i] + " ";
		}
	}

	return objRet;
}

function split_chars_words(text, len)
{
	arr = text.split(" ");
	var objRet = new Array(2);
	objRet[0] = text.substr(0, len -1) + "-";
	objRet[1] = text.substr(len-1, text.length);

	return objRet;
}

function align_right(text, len){
	right_space = len - text.length;
	return print_whitespace(right_space) + text;
}

function align_left(text, len){
	left_space = len - text.length;
	return text + print_whitespace(left_space);
}

function align_center(text, len){
	left_space = (len - text.length) / 2;
	return print_whitespace(left_space) + text	+ print_whitespace((len - text.length) - left_space);
}

function print_whitespace(len){
	var objReturn = "";
	var i=0;
	for(i=0; i<len; i++){
		objReturn += " ";
	}
	return objReturn;
}

function fixHTML(html) { return html.replace(/ /g, "&nbsp;").replace(/â€™/g, "'").replace(/-/g,"&#8209;"); }

function monitorFinding() 
{
	if (applet != null) {

	   if (!applet.isDoneFinding()) {
	   		window.setTimeout('monitorFinding()', 100);
	   } else {

	   	var printername = $("#printername").val();
	    var printers = applet.getPrinters().split(",");

			for (p in printers) {
				if(printers[p].indexOf(printername) >= 0)
				{
					applet.setPrinter(p);
				}
			}

		    if (applet.getPrinter() == null) {
		        return;
		    }

	    	if ($('#bkk_printmatrix').length > 0) { $('#bkk_printmatrix').show(); }
			if ($('#order_printmatrix').length > 0) { $('#order_printmatrix').show(); }
			if ($('#premi_printmatrix').length > 0) { $('#premi_printmatrix').show(); }
			if ($('#payroll_printmatrix').length > 0) { $('#payroll_printmatrix').show(); }

	   	}
	} 
	else 
	{
        /*alert("Applet not loaded!");*/
    }
   
}

function addComma(text, add) {
	if (text != "") {
		return text + ", " + add;
	} else {
		return add;		
	}
}

function isNumberKey(evt) { 
	var charCode = (evt.which) ? evt.which : event.keyCode
	if (charCode > 31 && (charCode < 48 || charCode > 57))
		return false;
	return true;
}

function isMoneyKey(evt) { 
	var charCode = (evt.which) ? evt.which : event.keyCode
	if (charCode > 31 && (charCode < 48 || charCode > 57))
	{
		if (charCode == 44 || charCode == 46)
			return true
		else
			return false;
	}
	return true;
}

function isDecimalKey(evt) { 
	var charCode = (evt.which) ? evt.which : event.keyCode
	if (charCode > 31 && (charCode < 48 || charCode > 57))
	{
		if (charCode == 44)
			return true
		else
			return false;
	}
	return true;
}

function toFormatMoney(x){
	
	var a =  Number($(x).val().split('.').join('').replace(',','.'));
	$(x).val(a.formatMoney(2,',','.'));
	return true;
}

function showMessageBox(text, timer) {
	$('#msg-box p').html(text);
	$('#msg-box').fadeIn();

	if (timer > 0) {
		setTimeout(function(){$("#msg-box").fadeOut();}, timer);		
	}
}

function getCashierRequests() {
	$.ajax({
		type: "GET",
		url: "/cashiers/getrequests/" + $('#datehidden').val(),
		success: function(data) {
			$('#cashier-requests').html(data.html);
			$('#strCash').html(data.total + ",00");
			
			
			$(".tablesorter").tablesorter({
				cssInfoBlock : "tablesorter-no-sort",
				widgets: ['filter'],
				widgetOptions : {
					filter_columnFilters : true
				}
			});
			

			$('#cashier-ref').text('Refresh Data Permintaan');			
		},
		request: function() {
			$('#cashier-ref').text('<em>Mengunduh Data</em>');			
		},
		failure: function() {
			alert("Error. Mohon refresh browser Anda.");
			$('#cashier-ref').text('Refresh Data Permintaan');			
		}
	});	
}

function getCustomerId() {
	var route_id = $('#invoice_route_id').val();
	$.ajax({
		type: "GET",
		url: "/invoices/getcustomerid/" + route_id,
		success: function(data) {
			$('#invoice_customer_id').html(data.customer_id);
			$(".chzn-select").chosen();
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	
}

function getCustomerForQuotation(value) {
	$.ajax({
		type: "GET",
		url: "/quotationgroups/getcustomer/" + value,
		success: function(data) {
			$('#div-customer').html(data.html);
			$(".chzn-select").chosen();
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	
}

$(document).ready(function() {


	if($('#content-full').hasClass('invtrain')) {
		$(".isotank_id").show();
		$(".container_id").hide();
		$(".routetrain_id").show();
		console.log('Inv Train!');
	}
	

  $('input[type="radio"][data-behavior="toggle-train"]').click(function(evt) {
    if($(this).val() == "true") { 
        var op = document.getElementById("invoice_tanktype").getElementsByTagName("option");
        for (var i = 0; i < op.length; i++) {
          // lowercase comparison for case-insensitivity
          (op[i].value.toLowerCase() == "tangki") 
            ? op[i].disabled = true 
            : op[i].disabled = false ;
            
          (op[i].value.toLowerCase() == "isotank") 
            ? op[i].selected = true 
            : op[i].selected = false ;
            $(".isotank_id").show();
            $(".container_id").hide();
			$(".routetrain_id").show();
        }
    } 
  });
});

$(document).ready(function() {
  $('input[type="radio"][data-behavior="toggle-standart"]').click(function(evt) {
    if($(this).val() == "false") { 
        var op = document.getElementById("invoice_tanktype").getElementsByTagName("option");
        for (var i = 0; i < op.length; i++) {
          op[i].disabled = false; 
          (op[i].value.toLowerCase() == "tangki") 
            ? op[i].selected = true 
            : op[i].selected = false ;
            $(".isotank_id").hide();
            $(".container_id").hide();
			$(".routetrain_id").hide();
        }
    } 
  });
});

function getRoutesOnly(customer_id) {
	$.ajax({
		type: "GET",
		url: "/invoices/getroutes/" + customer_id,
		success: function(data) {
            console.log("/invoices/get_routeswithtype/" + customer_id);
			$('#div_routes').html(data.html);
			$(".chzn-select").chosen();
		},
		request: function() {
			$('#div_routes').html('<em>Mengunduh Data</em>');			
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getRoutesOnly2(customer_id) {
	$.ajax({
		type: "GET",
		url: "/invoices/get_routesonly/" + customer_id,
		success: function(data) {
            console.log("/invoices/get_routesonly/" + customer_id);
			$('#div_routes').html(data.html);
			$(".chzn-select").chosen();
		},
		request: function() {
			$('#div_routes').html('<em>Mengunduh Data</em>');			
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});

	getunpaidinvoice(customer_id);
}

function getunpaidinvoice(customer_id){
	$.ajax({
		type: "GET",
		url: "/events/get_unpaid_inv?customer_id=" + customer_id,
		success: function(data) {
			$('#event_unpaid_inv').html(data.html);
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getRouteTrain(operator_id) {
	$.ajax({
		type: "GET",
		url: "/invoices/get_trainroute/" + operator_id,
		success: function(data) {
            console.log("/invoices/get_trainroute/" + operator_id);
			$('#div_routetrains').html(data.html);
			$(".chzn-select").chosen();
		},
		request: function() {
			$('#div_routetrains').html('<em>Mengunduh Data</em>');			
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getRouteShip(operator_id) {
	$.ajax({
		type: "GET",
		url: "/invoices/get_shiproute/" + operator_id,
		success: function(data) {
            console.log("/invoices/get_shiproute/" + operator_id);
			$('#div_routeships').html(data.html);
			$(".chzn-select").chosen();
		},
		request: function() {
			$('#div_routeships').html('<em>Mengunduh Data</em>');			
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getRouteTrain2(operator_id) {
	$.ajax({
		type: "GET",
		url: "/invoices/get_trainroute2/" + operator_id,
		success: function(data) {
			console.log("/invoices/get_trainroute2/" + operator_id);
			$('#div_routetrains').html(data.html);
			$(".chzn-select").chosen();
		},
		request: function() {
			$('#div_routetrains').html('<em>Mengunduh Data</em>');			
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getRoutes(customer_id) {
	$("#route-loader").show();

	kosonganType = $("#invoice_kosongan_type").val();
    
	if (document.getElementById('invoice_invoicetrain_true').checked) {
			var transporttype = "1";
	} else {
			var transporttype = "0";
	}

	$.ajax({
		type: "GET",
		url: "/invoices/getroutes/" + customer_id + "?train=" + transporttype + "&kosongan=" + kosonganType,
		success: function(data) {
			// console.log("/invoices/getroutes/" + customer_id + "?train=" + transporttype);
			$('#div_routes').html(data.html);
			$(".chzn-select").chosen();
			$("#route-loader").hide();
		},
		request: function() {
			$('#div_routes').html('<em>Mengunduh Data</em>');			
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	
    
    $.ajax({
		type: "GET",
		url: "/events/get_event_by_customer/" + customer_id + "?train=" + transporttype,
		success: function(data) {
			$('#div_events').html(data.html);
			$(".chzn-select").chosen();
		},
		request: function() {
			$('#div_events').html('<em>Mengunduh Data</em>');			
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
		
}

function getRouteTrains(operator_id) {

	$.ajax({
		type: "GET",
		url: "/reports/getroutetrains/" + operator_id,
		success: function(data) {
			console.log("/reports/getroutetrains/" + operator_id);
			$('#route-trains').html(data.html);
			$(".chzn-select").chosen();
		},
		request: function() {
			$('#route-trains').html('<em>Mengunduh Data</em>');			
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	
}

function getRoutesWithTransportType(customer_id) {

	var transporttype = $("#invoice_transporttype").val();

	$.ajax({
		type: "GET",
		url: "/invoices/getrouteswithtype/" + customer_id + "/" + transporttype,
		success: function(data) {
			$('#div_routes').html(data.html);
			$(".chzn-select").chosen();
		},
		request: function() {
			$('#div_routes').html('<em>Mengunduh Data</em>');			
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
    
    $.ajax({
		type: "GET",
		url: "/events/get_event_by_customer/" + customer_id,
		success: function(data) {
			$('#div_events').html(data.html);
			$(".chzn-select").chosen();
		},
		request: function() {
			$('#div_events').html('<em>Mengunduh Data</em>');			
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	
}

function getDriverPhone(driver_id) {
	$.ajax({
		type: "GET",
		url: "/invoices/getdriverphone/" + driver_id,
		success: function(data) {
			$('#phone_driver').val(data.driver_phone);
			// $(".chzn-select").chosen();
		},
		request: function() {
			$('#phone_driver').html('<em>Mengunduh Data</em>');			
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	
}

function getVehiclesByOffice(office_id, train, kosongan){

	if (kosongan == true && office_id != 0) {
		getCustomer(office_id);

		$.ajax({
			type: "GET",
			url: "/invoices/getvehiclesbyofficeid/" + office_id + "?train=" + train,
			success: function(data) {
				$('#div_vehicles').html(data.html);
				$(".chzn-select").chosen();
			},
			failure: function() {alert("Error. Mohon refresh browser Anda.");}
		});

	} else if(office_id != 0) {
		$.ajax({
			type: "GET",
			url: "/invoices/getvehiclesbyofficeid/" + office_id + "?train=" + train,
			success: function(data) {
				$('#div_vehicles').html(data.html);
				$(".chzn-select").chosen();
			},
			failure: function() {alert("Error. Mohon refresh browser Anda.");}
		});

	} else {
		if ($('#invoice_total').val() == '0') {
			$('#invoice_submit').hide();
		} else {
			$('#invoice_submit').show();		
		}
	}
}

function getTonage(price_per_type) {
	$.ajax({
		type: "GET",
		url: "/events/estimate_tonage/" + price_per_type,
		success: function(data) {
            console.log("/events/estimate_tonage/" + price_per_type);
			$('#div_tonage').html(data.html);
		},
		request: function() {
			$('#div_tonage').html('<em>Mengunduh Data</em>');			
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getAllowances() {
	var ishelper = false;
	if($("#need_helper").prop('checked'))
	{
		ishelper = true;
	}
    
    
    var ispremi = false;
	if($("#premi").prop('checked'))
	{
		ispremi = true;
	}

	qty = $("#invoice_quantity").val();

	$.ajax({
		type: "GET",
		url: "/invoices/getallowances/" + $('#invoice_route_id').attr('value') + '/' + $('#invoice_vehicle_id').attr('value') + '/' + $('#invoice_trip_type').attr('value') + '/' + $('#invoice_quantity').attr('value') + '/' + ishelper + '/' + ispremi,
		// url: "/invoices/getallowances/" + $('#invoice_route_id').attr('value') + '/' + $('#invoice_vehicle_id').attr('value') + '/' + 1 + '/' + $('#invoice_quantity').attr('value') + '/' + ishelper,
		beforeSend: function(){
			$('#invoice_incentive').html('-');	
			$('#invoice_price_per').val('-');	
			$('#invoice_driver_allowance').val('-');
			$('#invoice_helper_allowance').val('-');
			$('#invoice_misc_allowance').val('-');
			$('#invoice_gas_allowance').val('-');
			$('#invoice_gas_litre').val('-');
			$('#invoice_ferry_fee').val('-');
			$('#invoice_tol_fee').val('-');
			$('#invoice_gas_detail').html('-');
			$('#invoice_train_fee').html('-');
            $('#invoice_premi_allowance').val('-');
			$('#invoice_total').val('(menghitung)');
		},
		success: function(data) {
			$('#invoice_incentive').html('(@ ' + data.incentive + ')');	
			//$('#invoice_price_per').val(data.price_per);	
			$('#invoice_driver_allowance').val(data.driver_allowance);
			$('#invoice_helper_allowance').val(data.helper_allowance);
			$('#invoice_misc_allowance').val(data.misc_allowance);
			$('#invoice_gas_allowance').val(data.gas_allowance);
			$('#invoice_gas_litre').val(data.gas_litre);
			$('#invoice_ferry_fee').val(data.ferry_fee);
			$('#invoice_tol_fee').val(data.tol_fee);
			$('#invoice_gas_detail').html(data.gas_detail);
			$('#invoice_additional_gas_allowance').html(data.additional_gas_allowance);
			$('#invoice_additional_gas_detail').html(data.additional_gas_detail);
			$('#invoice_additional_tol_fee').html(data.additional_tol_fee);
			$('#invoice_train_fee').html(data.train_trip);
            $('#invoice_premi_allowance').html('(@ ' + data.premi_allowance + ')');	
			$('#invoice_total').val(data.total);
			checkAllowances();

			$(".chzn-select").chosen();
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getCustomer(office_id)
{
	$.ajax({
		type: "GET",
		url: "/invoices/getcustomer/" + office_id,
		success: function(data) {
			$('#div_customer').html(data.html);
			$(".chzn-select").chosen();
		},
		request: function() {
			$('#div_customer').html('<em>Mengunduh Data</em>');			
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	
}

function getVehicleGroup(vehicle_id)
{
	$.ajax({
		type: "GET",
		url: "/invoices/getvehiclegroup/" + vehicle_id,
		success: function(data) {
			$('#div_vehiclegroup').html(data.html);
			$(".chzn-select").chosen();
		},
		request: function() {
			$('#div_vehiclegroup').html('<em>Mengunduh Data</em>');			
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	
}

function resetAllowances() {
	$('.allowance-field').val('0');
	$('#invoice_submit').hide();
}

function checkAllowances() {
	if ($('#invoice_total').val() == '0') {
		$('#invoice_submit').hide();
	} else {
		$('#invoice_submit').show();		
	}	
}

function showPaymentship(){
	if ($('#div_ship').hasClass("div_ship")) {
		$('#div_payment_ship').show()
	}
}

function changeDriverAllowance(qty) {
	$('#invoicereturn_driver_allowance').val(Number($('#invoicereturn_price_per').val()) * parseInt(qty));
	$('#invoicereturn_helper_allowance').val(Number($('#invoicereturn_helper_trip').val()) * parseInt(qty));
	$('#invoicereturn_misc_allowance').val(Number($('#invoicereturn_misc_per').val()) * parseInt(qty));
	$('#invoicereturn_gas_leftover').val(Number($('#invoicereturn_gas_per').val()) * parseInt(qty));
	$('#invoicereturn_ferry_fee').val(Number($('#invoicereturn_ferry_per').val()) * parseInt(qty));
	$('#invoicereturn_tol_fee').val(Number($('#invoicereturn_tol_per').val()) * parseInt(qty));
}

function changeBonus(qty) {
	$('#bonusreceipt_total_bonus').val(Number($('#bonus_route').val()) * parseInt(qty));
}

function deleteSentDateLog(id) {
	$.ajax({
		type: "POST",
		url: "/taxinvoices/deletesentdatelog/" + id,
		beforeSend: function() {
			confirm('Apakah Anda yakin ingin menghapus aktivitas ini?');
		},
		success: function(data) {
			$('#activity_' + id).remove();
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getVehicles(vehiclegroup_id) {
	$.ajax({
		type: "GET",
		url: "/invoices/getvehicles/" + vehiclegroup_id,
		success: function(data) {
			$('#div_vehicle').html(data.html);
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getSentDateLog()
{
	var taxinvoice_id = $("#taxinvoice_id").val();

	$.ajax({
		type: "GET",
		url: "/taxinvoices/getsentdatelog/" + taxinvoice_id,
		success: function(data) {
			$('#sentdate_log').html(data.html);
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getTaxinvoicesByCustomer(customer_id) {
	$.ajax({
		type: "GET",
		url: "/taxinvoiceattachments/gettaxinvoicesbycustomer/" + customer_id,
		success: function(data) {
			$('#div_taxinvoice').html(data.html);
			$(".chzn-select").chosen();
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getTaxinvoiceItems()
{
	var taxinvoice_id = $("#taxinvoice_id").val();
	var customer_id = $("#customer_id").val();
	var is_wholesale = false;

	if($('#chk_is_wholesale').prop('checked'))
	{
		is_wholesale = true;
	}

	$.ajax({
		type: "GET",
		url: "/taxinvoices/gettaxinvoiceitems/" + taxinvoice_id + "/" + customer_id+ "/" + is_wholesale,
		success: function(data) {
			$('#div_additionalitem').html(data.html);
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function adjustGas() {
	var gas_start = $('#invoice_gas_start').val();
	var gas_voucher = 0;
	if ($.trim($("#invoice_gas_voucher").val())) {
    	gas_voucher = $("#invoice_gas_voucher").val();
	}
	
	var gas_leftover = 0;
	if ($.trim($("#invoice_gas_leftover").val())) {
    	gas_leftover = $("#invoice_gas_leftover").val();
	}

	var gas_cost = $('#invoice_gas_cost').val();
	var gas_allowance = $('#invoice_gas_allowance').val();

	//check max litre
	var max_litre = $('#invoice_max_litre').val();
	if (parseInt(gas_leftover) > parseInt(max_litre)) {
		gas_leftover = max_litre;
		$('#invoice_gas_leftover').val(gas_leftover);
		alert('Potongan tidak boleh melebihi gantungan ' + max_litre + ' liter.')
	}

	var gas_total = parseInt(gas_start) - parseInt(gas_voucher) - parseInt(gas_leftover);
	var gas_allowance_new = 0;
	if(gas_total > 0) gas_allowance_new = gas_total * Number(gas_cost);

	var total = $('#invoice_total').val();
	total = Number(total.split('.').join('')) - Number(gas_allowance.split('.').join('')) + Number(gas_allowance_new);

	$('#invoice_gas_litre').val(gas_total);
	$('#invoice_gas_allowance').val(gas_allowance_new.formatMoney(0,',','.'));
	$('#invoice_total').val(total.formatMoney(0,',','.'));
	$('#invoice_gas_detail').html('(' + gas_total + ' liter @ ' + gas_cost + ')');
}

function getWeightLost(id) {
	var gross = $('#weight_gross_' + id).val();
	var net = $('#weight_net_' + id).val();
	var price = $('#price_per').val();
	var price_new = $('#price_per_new').val();
	var total = 0;

	if(Number(price) != Number(price_new))
	{
		price = price_new;
	}

	if(Number(price) >= 300000){
		total = Number(price);
	}else{
		total = Number(net) * Number(price);
	}
	
	$('#txt_weight_lost_' + id).html(Number(gross) - Number(net));
	$('#txt_total_' + id).html(total.formatMoney(2,',','.'));
	$('#total_' + id).val(total);
}

function changeTaxes() {
	
	var gst_tax = 0;
	var price_tax = 0;

    var ppn = Number($('#ppn').val());

	if ($("#taxinvoice_subtotal").length > 0) {
		var total = Number($('#taxinvoice_subtotal').val());
	} else {
		var total = 0;
	}

	if ($("#taxinvoice_dp_cost").length > 0) {
		var dp_cost = Number($('#taxinvoice_dp_cost').val().split('.').join('').replace(',','.'));
	} else {
		var dp_cost = 0;
	}

	var extra_cost = Number($('#taxinvoice_extra_cost').val().split('.').join('').replace(',','.'));
	var insurance_cost = Number($('#taxinvoice_insurance_cost').val().split('.').join('').replace(',','.'));
	var claim_cost = Number($('#taxinvoice_claim_cost').val().split('.').join('').replace(',','.'));

	if ($(".gst_tax:checked").length > 0) {
		ppn = $(".gst_tax:checked").first().val();
		gst_tax = (total + extra_cost + dp_cost) * (ppn/100);
		$("#ppn_amount").text((ppn));
		if (parseFloat($(".gst_tax:checked").val()) > 0) {
			$("#ppn-row").show();
		}else{
			$("#ppn-row").hide();
		}
	}
	// if ($('#chk_gst_tax').prop('checked')) {
	// 	gst_tax = (total + extra_cost) * (ppn/100);
	// }
	if ($('#chk_price_tax').prop('checked')) {
		price_tax = (total + extra_cost + dp_cost) * 0.02;
	}

	var is_rounded = $("#is_rounded").is(":checked");


	if ($("#edited").length > 0) {
		total += extra_cost + gst_tax - insurance_cost - price_tax - claim_cost - dp_cost;
	} else {
		total += dp_cost + extra_cost + gst_tax - insurance_cost - price_tax - claim_cost;
	}
	

	$('#txt_dp_cost').html(dp_cost.formatMoney(2,',','.'));
	$('#txt_extra_cost').html(extra_cost.formatMoney(2,',','.'));
	$('#txt_gst_tax').html(gst_tax.formatMoney(2,',','.'));
	
	if(price_tax > 0){
		$('#txt_price_tax').attr('class','red');
	}else{
		$('#txt_price_tax').removeAttr('class');
	}
	price_tax = 0 - price_tax;
	$('#txt_price_tax').html(price_tax.formatMoney(2,',','.'))

	if(insurance_cost > 0){
		$('#txt_insurance_cost').attr('class','red');
	}else{
		$('#txt_insurance_cost').removeAttr('class');
	}
	insurance_cost = 0 - insurance_cost
	$('#txt_insurance_cost').html(insurance_cost.formatMoney(2,',','.'));

	if(claim_cost > 0){
		$('#txt_claim_cost').attr('class','red');
	}else{
		$('#txt_claim_cost').removeAttr('class');
	}
	claim_cost = 0 - claim_cost
	$('#txt_claim_cost').html(claim_cost.formatMoney(2,',','.'));

	if (is_rounded) {
		$('#txt_total').html(total.formatMoney(0,',','.'));
	} else {
		$('#txt_total').html(total.formatMoney(2,',','.'));
	}
}

function countTotalTaxInvoiceItems(){
	var totalqty = 0;
	var totalgross = 0;
	var total = 0;
	if($('#tbItem').length > 0){
		$('#tbItem > tbody > tr').each(function() {
			id = $(this).attr("id");
			if($('#cb_' + id).prop('checked')){
				if($('#process').val() == 'edit'){
					if(parseInt(id) > 0){
						total += Number($('#total_'+id).html().split('.').join('').replace(',','.'));
						totalqty += Number($('#qty_'+id).val());
						totalgross += Number($('#gross_'+id).val());
					}
				}else{
					if(parseInt(id) > 0){
						if($('#cb_' + id).prop('checked')){
							total += Number($('#total_'+id).html().split('.').join('').replace(',','.'));
							totalqty += Number($('#qty_'+id).val());
							totalgross += Number($('#gross_'+id).val());
						}
					}
				}
			}
		});	
	}

	if($('#vendortbItem').length > 0){
		$('#vendortbItem > tbody > tr').each(function() {
			id = $(this).attr("id");
			if($('#vendorcb_' + id).prop('checked')){
				if($('#process').val() == 'edit'){
					if(parseInt(id) > 0){
						total += Number($('#total_'+id).html().split('.').join('').replace(',','.'));
						totalqty += Number($('#qty_'+id).val());
						totalgross += Number($('#gross_'+id).val());
					}
				}else{
					if(parseInt(id) > 0){
						if($('#vendorcb_' + id).prop('checked')){
							total += Number($('#total_'+id).html().split('.').join('').replace(',','.'));
							totalqty += Number($('#qty_'+id).val());
							totalgross += Number($('#gross_'+id).val());
						}
					}
				}
			}
		});	
	}
		
	if($('#tbAdditional').length > 0){
		$('#tbAdditional > tbody > tr').each(function() {
			id = $(this).attr("id");
			if($('#cb_' + id).prop('checked')){
				total += Number($('#total_'+id).html().split('.').join('').replace(',','.'));
				totalqty += Number($('#qty_'+id).html());
				totalgross += Number($('#gross_'+id).val());
			}
		});
	}
	
	
    $('#taxinvoice_subtotal').val(total);
    $('#lbl_subtotal').html(total.formatMoney(2,',','.'));
    $('#lbl_qtytotal').html(totalqty);
    $('#lbl_grosstotal').html(totalgross);
    changeTaxes();
}

function changeWholesalePriceInvoice(){
	var total = 0;
	var totalqty = 0;

	$('#tbItem > tbody > tr').each(function() {

		id = $(this).attr("id");
		if (parseInt(id) > 0) {
			if($("input:radio[name='price_by']:checked").val() == 'is_wholesale')
			{
				var price = Number($('#wholesale_price').val());
				$('#cbwholesale_'+id).attr('checked', true);
				$('#total_'+id).html(price.formatMoney(2,',','.'));
			}else if($("input:radio[name='price_by']:checked").val() == 'is_gross'){
				var qty = $('#gross_'+id).val().split('.').join('');
				var priceper = $('#priceper_'+id).val();
				var subtotal = 0 ;
				if(Number(priceper) >= 300000){
					subtotal = Number(priceper);
				}else
				{
					subtotal = Number(qty) * Number(priceper);
				}
				
				$('#cbwholesale_'+id).attr('checked', false);
				$('#total_'+id).html(subtotal.formatMoney(2,',','.'));
			}else{
				var qty = $('#qty_'+id).val().split('.').join('');
				var priceper = $('#priceper_'+id).val();
				var subtotal = 0 ;
				if(Number(priceper) >= 300000){
					subtotal = Number(priceper);
				}else
				{
					subtotal = Number(qty) * Number(priceper);
				}
				
				$('#cbwholesale_'+id).attr('checked', false);
				$('#total_'+id).html(subtotal.formatMoney(2,',','.'));
			}
		};

	});	

	if($('#tbAdditional').length > 0){
		$('#tbAdditional > tbody > tr').each(function() {

			id = $(this).attr("id");
			if (parseInt(id) > 0) {
				if($("input:radio[name='price_by']:checked").val() == 'is_wholesale')
				{
					var price = Number($('#wholesale_price').val());
					$('#cbwholesale_'+id).attr('checked', true);
					$('#total_'+id).html(price.formatMoney(2,',','.'));
				}else if($("input:radio[name='price_by']:checked").val() == 'is_gross'){
					var qty = $('#gross_'+id).val().split('.').join('');
					var priceper = $('#priceper_'+id);
					var subtotal = 0 ;
					if(Number(priceper) >= 300000){
						subtotal = Number(priceper);
					}else
					{
						subtotal = Number(qty) * Number(priceper);
					}
					$('#cbwholesale_'+id).attr('checked', false);
					$('#total_'+id).html(subtotal.formatMoney(2,',','.'));
				}else{
					var qty = $('#qty_'+id).val().split('.').join('');
					var priceper = $('#priceper_'+id).val();
					var subtotal = 0 ;
					if(Number(priceper) >= 300000){
						subtotal = Number(priceper);
					}else
					{
						subtotal = Number(qty) * Number(priceper);
					}
					$('#cbwholesale_'+id).attr('checked', false);
					$('#total_'+id).html(subtotal.formatMoney(2,',','.'));
				}
			};

		});
	}

    countTotalTaxInvoiceItems();
}

function countTotalInvoiceQty(taxinvoice_id)
{
	var totalitem = 0;

	if($("input:radio[name='price_by']:checked").val() == 'is_wholesale'){
		var price = $('#wholesale_price').val();

		totalitem = Number(price.split('.').join(''));
	}else if($("input:radio[name='price_by']:checked").val() == 'is_gross'){
		var priceper = Number($('#priceper_'+taxinvoice_id).val())
		if(priceper >= 300000)
		{
			totalitem = priceper;
		}
		else
		{
			totalitem = Number($('#gross_'+taxinvoice_id).val()) * priceper;	
		}
	}else{

		var priceper = Number($('#priceper_'+taxinvoice_id).val())
		if(priceper >= 300000)
		{
			totalitem = priceper;
		}
		else
		{
			totalitem = Number($('#qty_'+taxinvoice_id).val()) * priceper;	
		}
		
	}
	
	$('#total_'+taxinvoice_id).html(totalitem.formatMoney(2,',','.'));

	countTotalTaxInvoiceItems();
}

function taxinvoiceitemsReject(){
	if($('#rejected').prop('checked')){
		$('#rejectbox').show();
	} else {
		$('#rejectbox').hide();
	}
}

function checkAllTaxinvoiceitems(){
	if($('#is_all_wholesale').prop('checked'))
	{
		if($('#tbItem').length > 0){
			$('#tbItem > tbody > tr').each(function() {
				id = $(this).attr("id");
				if (parseInt(id) > 0) {
					$('#cb_' + id).attr('checked',true);
				}
			});
		}

	}else{
		if($('#tbItem').length > 0){
			$('#tbItem > tbody > tr').each(function() {
				id = $(this).attr("id");
				if (parseInt(id) > 0) {
					$('#cb_' + id).attr('checked',false);
				}
			});
		}
	}

	if($('#vendoris_all_wholesale').prop('checked'))
	{
		if($('#vendortbItem').length > 0){
			$('#vendortbItem > tbody > tr').each(function() {
				id = $(this).attr("id");
				if (parseInt(id) > 0) {
					$('#vendorcb_' + id).attr('checked',true);
				}
			});
		}

	}else{
		if($('#vendortbItem').length > 0){
			$('#vendortbItem > tbody > tr').each(function() {
				id = $(this).attr("id");
				if (parseInt(id) > 0) {
					$('#vendorcb_' + id).attr('checked',false);
				}
			});
		}
	}

	countTotalTaxInvoiceItems();
}

function checkAllTaxinvoices(){
	if($('#is_all_paid').prop('checked'))
	{
		if($('#indextaxinvoices').length > 0){
			$('#indextaxinvoices > tbody > tr').each(function() {
				id = $(this).attr("id");
				if (parseInt(id) > 0) {
					if($('#cb_' + id).attr('disabled') != "disabled")
					{
						$('#cb_' + id).attr('checked',true);
					}
				}
			});
		}
	}else{
		if($('#indextaxinvoices').length > 0){
			$('#indextaxinvoices > tbody > tr').each(function() {
				id = $(this).attr("id");
				if (parseInt(id) > 0) {
					if($('#cb_' + id).attr('disabled') != "disabled")
					{
						$('#cb_' + id).attr('checked',false);
					}
				}
			});
		}
	}
}

function countTotalInvoiceGeneric(taxgeneric_id)
{
	var totalitem = 0;

	if($("input:radio[name='price_by']:checked").val() == 'is_gross') {
		if ($('#_price_'+taxgeneric_id).val() >= 300000 ) {
			totalitem = 300000;
		}
		else {
			totalitem = Number($('#_gross_'+taxgeneric_id).val() * $('#_price_'+taxgeneric_id).val() );
		}
	}
	else {
		if ($('#_price_'+taxgeneric_id).val() >= 300000 ) {
			totalitem = 300000;
		}
		else {
			totalitem = Number($('#_net_'+taxgeneric_id).val() * $('#_price_'+taxgeneric_id).val() );
		}
	}
	var is_pembulatan = $("#is_rounded").is(":checked");
	if (is_pembulatan) {
		$('#_total_'+taxgeneric_id).html(totalitem.formatMoney(0,',','.'));
	}else{
		$('#_total_'+taxgeneric_id).html(totalitem.formatMoney(2,',','.'));
	}

	countTotalInvoiceGenericItems();
}

function changeCountRatesInvoiceGeneric()
{
	for(i=0; i<20; i++)
	{
		countTotalInvoiceGeneric(i);
	}	
}

function countTotalInvoiceGenericItems()
{
	var amount = 0;

	for(j=0; j<20; j++)
	{
		amount += Number($('#_total_'+j.toString()).html().split('.').join('').replace(',','.') );
	}
	
	$('#lbl_subtotal').html(amount.formatMoney(2,',','.'));
	changeTaxesGeneric();
}

function changeTaxesGeneric() {
	var gst_tax = 0;
	var price_tax = 0;

    var ppn = Number($('#ppn').val());
	var total = Number($('#lbl_subtotal').html().split('.').join('').replace(',','.') );
	var extra_cost = Number($('#taxinvoice_extra_cost').val().split('.').join('').replace(',','.'));
	var insurance_cost = Number($('#taxinvoice_insurance_cost').val().split('.').join('').replace(',','.'));
	var claim_cost = Number($('#taxinvoice_claim_cost').val().split('.').join('').replace(',','.'));

	if ($(".gst_tax:checked").length > 0) {
		ppn = $(".gst_tax:checked").first().val();
		gst_tax = (total + extra_cost) * (ppn/100);
		$("#ppn_amount").text((ppn));
	}
	if ($('#chk_price_tax').prop('checked')) {
		price_tax = (total + extra_cost) * 0.02;
	}

	var is_pembulatan = $("#is_rounded").is(":checked");
	total += extra_cost + gst_tax - price_tax - insurance_cost - claim_cost;

	$('#txt_extra_cost').html(extra_cost.formatMoney(2,',','.'));
	$('#txt_gst_tax').html(gst_tax.formatMoney(2,',','.'));

	if(price_tax > 0){
		$('#txt_price_tax').attr('class','red');
	}else{
		$('#txt_price_tax').removeAttr('class');
	}
	price_tax = 0 - price_tax;
	$('#txt_price_tax').html(price_tax.formatMoney(2,',','.'));

	if(insurance_cost > 0){
		$('#txt_insurance_cost').attr('class','red');
	}else{
		$('#txt_insurance_cost').removeAttr('class');
	}
	insurance_cost = 0 - insurance_cost
	$('#txt_insurance_cost').html(insurance_cost.formatMoney(2,',','.'));

	if(claim_cost > 0){
		$('#txt_claim_cost').attr('class','red');
	}else{
		$('#txt_claim_cost').removeAttr('class');
	}
	claim_cost = 0 - claim_cost
	$('#txt_claim_cost').html(claim_cost.formatMoney(2,',','.'));

	if (is_pembulatan) {
		$('#txt_total').html(total.formatMoney(0,',','.'));
	} else {
		$('#txt_total').html(total.formatMoney(2,',','.'));
	}
	console.log(total);
}

function countTotalPaymentcheck()
{
	total = 0;
	$(":input[name^='paymentcheck[cb_']").each(function() {
		if($(this).prop('checked'))
		{
			id = $(this).parent().attr("id");
			total += Number($('#productorder_total_'+id).html().split('.').join(''));
		}
    });	

    $('#txt_total').html(total.formatMoney(0,',','.'));
}

function toggleDetailBox(id) {
	$('#detail-' + id).fadeToggle();
}

function closeDetailBox(id) {
	$('#detail-' + id).fadeOut();
}

function getStockProduct(value, id){
	$('#productid_'+ id).val(value);	

	$.ajax({
		type: "GET",
		url: "/productrequests/getproductstocks/" + value,
		success: function(data) {
			var quantity = Number(data.quantity);
			$('#stock_'+ id).val(quantity.formatMoney(2,',','.'));				
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}



function minmax(value, min, max) 
{	
		$val = value.replace(',', '.');
		$max = max.replace(',', '.');

    if (parseFloat($val) < 0.0 || isNaN($val)) 
      return 0; 
    else if (parseFloat($val) > parseFloat($max)) {
      alert("Jumlah tidak boleh melebihi stock gudang");
      return max;
    }

    else return value;
}


function getPriceProductsale(value, id){
	$.ajax({
		type: "GET",
		url: "/sales/getpriceproductsale/" + value,
		success: function(data) {
			var price = Number(data.price);
			$('#price_'+ id).val(price.formatMoney(0,',','.'));		

			changeTotalProductsale(id);	

		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function changeTotalProductsale(id){
	var quantity = Number($("#quantity_" + id).val());
	var price = Number($("#price_"+id).val().split('.').join(''));
	var total = quantity * price;

	$("#total_"+id).val(total.formatMoney(0,',','.'));

	var totalsale = 0;

	$(":input[name^='sale[total']").each(function() {
       totalsale += Number($(this).val().split('.').join(''));
    });

    $('#totalsale').val(totalsale.formatMoney(0,',','.'));
}

function changeSubTotalProductOrder(id){
	var quantity = $('#po_quantity_'+id).val().replace(',','.');
	var priceper = $('#po_priceper_'+id).val();
	
	var subtotal = Number(quantity) * Number(priceper.split('.').join(''));

	$('#po_total_'+id).val(subtotal.formatMoney(0,',','.'));

	total = 0;
	$(":input[name^='productorder[subtotal_']").each(function() {
       total += Number($(this).val().split('.').join(''));
    });

    $('#po_total').val(total.formatMoney(0,',','.'));
}
function slugify(text) { return text.toLowerCase().replace(/[^a-z0-9]/g,"-"); }

function getDataEvents(cl)
{
	console.log(cl);
	var events = [];
	$.ajax({
		type: "GET",
		url: "/events/getevents/" + cl,
		success: function(data) {
            
            console.log(data);
            $(".loader.main-dashboard").removeClass('d-block').addClass('d-none');

			for (var i = 0; i < data.length; i++) {
				var object = data[i];    				
				var obj = new Object();

				obj.title = "#"+ object.id + " " + object.summary;
				obj.start = object.start_date.toString();
				obj.end = object.end_date.toString();

				if (cl == 'bookings') {
					obj.url = '/bookings/' + object.id + '/edit'
				} else {
					obj.url = '/events/' + object.id + '/edit'
				}

				if (object.handled) obj.className = 'handled';
				if (object.cancelled) obj.className = 'cancelled';
				if (object.is_booking) obj.className = 'is_booking';
				if (object.authorised) obj.className = 'authorised';
				if (object.half_completed) obj.className = 'half_completed';
				if (object.completed) obj.className = 'completed';
				if (object.completed_by_vendor) obj.className = 'completed_by_vendor';
				if (object.invoiced) obj.className = 'invoiced'; 
				if (object.downpayment_amount > 0) {
					obj.className += " dp";
					obj.title += " (*DP)";
				}
				if (object.is_stapel) {
					obj.className += " stapel";
					obj.title += " (*STP)";
				}
				if (object.is_insurance) {
					obj.title += " (*INS)";
				}

				if (object.customer_id > 0) obj.title += " (*P)";
				
				events.push(obj);
			}			
			
			var bigEvents= [];
			var a = new Object();
			a.events = events;	

			bigEvents.push(a);

			$('#calendar').fullCalendar({
				eventSources :JSON.parse(JSON.stringify(bigEvents))
    		});
			$('#arrayevents').val(JSON.stringify(bigEvents));	
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});		
}

function getDataEvents2(cl)
{
	console.log(cl);

	if (cl == 'drivers') {
		urlSet = "/drivers/getdaily";
	} else {
		urlSet = "/events/geteventsv2/" + cl;
	}

	var events = [];
	$.ajax({
		type: "GET",
		url: urlSet,
		success: function(data) {
            
            console.log(data);
            $(".loader.main-dashboard").removeClass('d-block').addClass('d-none');

			for (var i = 0; i < data.length; i++) {
				var object = data[i];    				
				var obj = new Object();

				if (cl == 'drivers') {
					obj.title = object.summary;
				} else {
					obj.title = "#"+ object.id + " " + object.summary;
				}
				
				obj.start = object.start_date.toString();
				obj.end = object.end_date.toString();

				if (cl == 'bookings') {
					obj.url = '/bookings/' + object.id + '/edit'
				} else {

					if (cl == 'drivers') {
						obj.url = '/drivers/' + object.id + '/edit'
					} else {
						obj.url = '/events/' + object.id + '/edit'
					}
				}

				if (object.handled) obj.className = 'handled';
				if (object.cancelled) obj.className = 'cancelled';
				if (object.is_booking) obj.className = 'is_booking';
				if (object.authorised) obj.className = 'authorised';
				if (object.half_completed) obj.className = 'half_completed';
				if (object.completed) obj.className = 'completed';
				if (object.completed_by_vendor) obj.className = 'completed_by_vendor';
				if (object.invoiced) obj.className = 'invoiced'; 
				// if (object.taxinvoiced) obj.className = 'taxinvoiced'; 

				if (object.downpayment_amount > 0) {
					obj.className += " dp";
					obj.title += " (*DP)";
				}
				if (object.is_stapel) {
					obj.className += " stapel";
					obj.title += " (*STP)";
				}
				if (object.is_insurance) {
					obj.title += " (*INS)";
				}
				if (object.taxinvoiced) {
					obj.className += " taxinvoiced";
					obj.title += " (*INV)";
				}
				if (object.customer_id > 0) obj.title += " (*P)";
				
				events.push(obj);
			}			
			
			var bigEvents= [];
			var a = new Object();
			a.events = events;	

			bigEvents.push(a);

			$('#calendar2').fullCalendar({
				eventSources :JSON.parse(JSON.stringify(bigEvents))
    		});
			$('#arrayevents').val(JSON.stringify(bigEvents));	
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});		
}

function resyncEvent(){

	$('#resync').html('<i class="icon-refresh"></i> &nbsp;Sync...');

	$.ajax({
		type: "GET",
		url: "/events/resync",
		success: function(data) {
			getDataEvents2($('#calendar2').attr('class'));
			$('#resync').html('<i class="icon-refresh"></i> &nbsp;Re-Sync');
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	}); 
}


function getDataBookings(cl)
{
	var bookings = [];
	$.ajax({
		type: "GET",
		url: "/bookings/getbookings/" + cl,
		success: function(data) {
            
            console.log(data);
            $(".loader.main-dashboard").removeClass('d-block').addClass('d-none');

			for (var i = 0; i < data.length; i++) {
				var object = data[i];    				
				var obj = new Object();

				obj.title = "#"+ object.id + " " + object.description;
				obj.start = object.date.toString();
				obj.end = object.date.toString();
				obj.url = '/bookings/' + object.id + '/edit'

				// if (object.completed) obj.className = 'completed';
				// if (object.customer_id > 0) obj.title += " (*P)";
				
				bookings.push(obj);
			}			
			
			var bigBookings= [];
			var a = new Object();
			a.bookings = bookings;	

			bigBookings.push(a);

			$('#calendarBookings').fullCalendar({
				eventSources :JSON.parse(JSON.stringify(bigBookings))
    		});
			$('#arraybookings').val(JSON.stringify(bigBookings));	
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});		
}

function getDoVendor() {
	if ($('#event_need_vendor').prop('checked') == true) {
		$('#dov-loader').show();
		$.ajax({
			type: "GET",
			url: "/events/getdovendor",
			success: function(data) {
				$('#div-dovendor').html(data.html);
				$(".chzn-select").chosen();
				$('#dov-loader').hide();
			},
			failure: function() {alert("Error. Mohon refresh browser Anda.");}
		});
	} else {
		$('#div-dovendor').empty();
	}
}

function getDovRoute(customer_id) {
	$('#dov-loader').show();
	$.ajax({
		type: "GET",
		url: "/events/getdovroutes/" + customer_id,
		success: function(data) {
			$('#div-dovroutes').html(data.html);
			$(".chzn-select").chosen();
			$('#dov-loader').hide();
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getDovVendor(multimoda) {
	$('#dov-loader').show();
	$.ajax({
		type: "GET",
		url: "/events/getdovvendors/" + multimoda,
		success: function(data) {
			$('#div-dovvendor').html(data.html);
			$(".chzn-select").chosen();
			$('#dov-loader').hide();
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getDovVendorroute(vendor_id) {
	$('#dov-loader').show();
	$.ajax({
		type: "GET",
		url: "/events/getdovvendorroutes/" + vendor_id,
		success: function(data) {
			$('#div-dovvendorroutes').html(data.html);
			$(".chzn-select").chosen();
			$('#dov-loader').hide();
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getGraphIncomeVehicle()
{
	var year = $("#year").val();
	
	$.ajax({
		type: "GET",
		url: "/dashboards/getincomevehicledata/" + year,
		success: function(data) {
			$.jqplot('chartincomevehicle',  data, {
		        seriesDefaults: {
		            renderer:$.jqplot.BarRenderer,
		            barPadding: 20,
		            barMargin: 30,
		            pointLabels: { show: true, location: 'e', edgeTolerance: -15 },
		            color: '#00A651',
		            shadowAngle: 135,
		            
		            rendererOptions: {
		                barDirection: 'horizontal',
		                barWidth: 15
		            }
		        },
		        axes: {
		        	xasis:{
		        		 max: 10000000,
		        		 pad: 2.5
		        	},
		            yaxis: {
		                renderer: $.jqplot.CategoryAxisRenderer,
		                max: 10000000
		            }
		        }
			}).replot();		

		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	
}

function getGraphExpenseVehicle()
{
	var year = $("#year").val();
	
	$.ajax({
		type: "GET",
		url: "/dashboards/getexpensevehicledata/" + year,
		success: function(data) {
			$.jqplot('chartexpensevehicle',  data, {
		        seriesDefaults: {
		            renderer:$.jqplot.BarRenderer,
		            barPadding: 20,
		            barMargin: 30,
		            pointLabels: { show: true, location: 'e', edgeTolerance: -15 },
		            color: '#CC0033',
		            shadowAngle: 135,
		            
		            rendererOptions: {
		                barDirection: 'horizontal',
		                barWidth: 15
		            }
		        },
		        axes: {
		        	xasis:{
		        		 max: 10000000,
		        		 pad: 2.5
		        	},
		            yaxis: {
		                renderer: $.jqplot.CategoryAxisRenderer,
		                max: 10000000
		            }
		        }
			}).replot();		

		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	
}

function getGraphAnnualReportVehicle()
{
	var vehicle_id = $("#vehicle_id").val();
	var ticks = ['Januari','Februari', 'Maret','April','Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
	$.ajax({
		type: "GET",
		url: "/reports/getannualreportvehicle/" + vehicle_id,
		success: function(data) {
			$.jqplot('div_annualvehiclegraph', data, {
				seriesColors:['#00A651', '#CC0033'],
		        seriesDefaults:{
		            renderer:$.jqplot.BarRenderer,
		            rendererOptions: {fillToZero: true},
		            pointLabels: { show: true },
		        },
		        series:[
		            {label:'Pemasukan (*1000)'},
		            {label:'Pengeluaran (*1000)'},
		        ],
		        legend: {
		            show: true,
		            placement: 'outsideGrid'
		        },
		        axes: {
		           
		            xaxis: {
		                renderer: $.jqplot.CategoryAxisRenderer,
		                ticks: ticks
					},
		            
		            yaxis: {
		                pad: 1.05,
		                tickOptions: {formatString: '%d'}
		            }
		        }
		    }).replot();		

		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	
}

function getGraphCustomer()
{
	var year = $("#year").val();
	
	$.ajax({
		type: "GET",
		url: "/reports/getcustomerdata/" + year,
		success: function(data) {
			$.jqplot('chartcustomer',  data, {
		        seriesDefaults: {
		            renderer:$.jqplot.BarRenderer,
		            barPadding: 20,
		            barMargin: 30,
		            pointLabels: { show: true, location: 'e', edgeTolerance: -15 },
		            color: '#00A651',
		            shadowAngle: 135,
		            
		            rendererOptions: {
		                barDirection: 'horizontal',
		                barWidth: 15
		            }
		        },
		        axes: {
		        	xasis:{
		        		 max: 10000000,
		        		 pad: 2.5
		        	},
		            yaxis: {
		                renderer: $.jqplot.CategoryAxisRenderer,
		                max: 10000000
		            }
		        }
			}).replot();		

		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	
}

function getBranchStats(){

	var startdate = $("#startdate").val();
    var enddate = $("#enddate").val();
    
    $.ajax({
		type: "GET",
		url: "/reports/getbranchstats?type=customers&startdate=" + startdate + "&enddate=" + enddate,
		success: function(data) {

			var thestats = data.customers;

			console.log(thestats);
			if (window.ApexCharts) {
				var options = {
					series: [{
						name: 'Jumlah Pelanggan Unik',
						data: thestats
					}],
					chart: {
						type: 'bar',
						height: 320
					},
					plotOptions: {
						bar: {
							borderRadius: 4,
							borderRadiusApplication: 'end',
							horizontal: false
						}
					},
					dataLabels: {
						enabled: true
					},
					xaxis: {
						categories: ['Sidoarjo', 'Jakarta', 'Probolinggo', 'Semarang', 'Surabaya']
					},
					colors:['#31bfff']
				};
		
				var chart = new ApexCharts($("#customers-stats")[0], options);
				chart.render();
			}
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	

	$.ajax({
		type: "GET",
		url: "/reports/getbranchstats?type=events&startdate=" + startdate + "&enddate=" + enddate,
		success: function(data) {

			var thestats = data.events;

			console.log(thestats);
			if (window.ApexCharts) {
				var options = {
					series: [{
						name: 'Jumlah KE',
						data: thestats
					}],
					chart: {
						type: 'bar',
						height: 320
					},
					plotOptions: {
						bar: {
							borderRadius: 4,
							borderRadiusApplication: 'end',
							horizontal: false
						}
					},
					dataLabels: {
						enabled: true
					},
					xaxis: {
						categories: ['Sidoarjo', 'Jakarta', 'Probolinggo', 'Semarang', 'Surabaya']
					}
				};
		
				var chart = new ApexCharts($("#events-stats")[0], options);
				chart.render();
			}
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	

	$.ajax({
		type: "GET",
		url: "/reports/getbranchstats?type=eventsomzet&startdate=" + startdate + "&enddate=" + enddate,
		success: function(data) {

			var thestats = data.estimations;

			console.log(thestats);
			if (window.ApexCharts) {
				var options = {
					series: [{
						name: 'Est. Omzet Cabang',
						data: thestats
					}],
					chart: {
						type: 'bar',
						height: 320
					},
					plotOptions: {
						bar: {
							borderRadius: 4,
							borderRadiusApplication: 'end',
							horizontal: false
						}
					},
					dataLabels: {
						enabled: false
					},
					xaxis: {
						categories: ['Sidoarjo', 'Jakarta', 'Probolinggo', 'Semarang', 'Surabaya']
					},
					colors:['#1fc20e']
				};
		
				var chart = new ApexCharts($("#events-omzet-stats")[0], options);
				chart.render();
			}
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	

	$.ajax({
		type: "GET",
		url: "/reports/getbranchstatsbkk?type=bkk&startdate=" + startdate + "&enddate=" + enddate,
		success: function(data) {

			var thestats = data.bkk;

			console.log(thestats);
			if (window.ApexCharts) {
				var options = {
					series: [{
						name: 'BKK Muat',
						data: thestats
					}],
					chart: {
						type: 'bar',
						height: 320
					},
					plotOptions: {
						bar: {
							borderRadius: 4,
							borderRadiusApplication: 'end',
							horizontal: false
						}
					},
					dataLabels: {
						enabled: true
					},
					xaxis: {
						categories: ['Sidoarjo', 'Jakarta', 'Probolinggo', 'Semarang', 'Surabaya']
					},
					colors:['#ff5f6a']
				};
		
				var chart = new ApexCharts($("#bkk-stats")[0], options);
				chart.render();
			}
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	

	$.ajax({
		type: "GET",
		url: "/reports/getbranchstatsbkk?type=kos&startdate=" + startdate + "&enddate=" + enddate,
		success: function(data) {

			var thestats = data.bkkkos;

			console.log(thestats);
			if (window.ApexCharts) {
				var options = {
					series: [{
						name: 'Kos Prod',
						data: thestats
					}],
					chart: {
						type: 'bar',
						height: 320
					},
					plotOptions: {
						bar: {
							borderRadius: 4,
							borderRadiusApplication: 'end',
							horizontal: false
						}
					},
					dataLabels: {
						enabled: true
					},
					xaxis: {
						categories: ['Sidoarjo', 'Jakarta', 'Probolinggo', 'Semarang', 'Surabaya']
					},
					colors:['#FF1020']
				};
		
				var chart = new ApexCharts($("#bkk-kos-stats")[0], options);
				chart.render();
			}
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	
	$.ajax({
		type: "GET",
		url: "/reports/getbranchstatsbkk?type=non&startdate=" + startdate + "&enddate=" + enddate,
		success: function(data) {

			var thestats = data.bkknon;

			console.log(thestats);
			if (window.ApexCharts) {
				var options = {
					series: [{
						name: 'Non Prod',
						data: thestats
					}],
					chart: {
						type: 'bar',
						height: 320
					},
					plotOptions: {
						bar: {
							borderRadius: 4,
							borderRadiusApplication: 'end',
							horizontal: false
						}
					},
					dataLabels: {
						enabled: true
					},
					xaxis: {
						categories: ['Sidoarjo', 'Jakarta', 'Probolinggo', 'Semarang', 'Surabaya']
					},
					colors:['#cf0000']
				};
		
				var chart = new ApexCharts($("#bkk-non-stats")[0], options);
				chart.render();
			}
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	

	// bkk-truk-stats
	$.ajax({
		type: "GET",
		url: "/reports/getbranchstatsbkkbreakdown?type=truk&startdate=" + startdate + "&enddate=" + enddate,
		success: function(data) {

			var thestats = data.bkktruk;

			console.log(thestats);
			if (window.ApexCharts) {
				var options = {
					series: [{
						name: 'BKK Truk',
						data: thestats
					}],
					chart: {
						type: 'bar',
						height: 320
					},
					plotOptions: {
						bar: {
							borderRadius: 4,
							borderRadiusApplication: 'end',
							horizontal: false
						}
					},
					dataLabels: {
						enabled: true
					},
					xaxis: {
						categories: ['Sidoarjo', 'Jakarta', 'Probolinggo', 'Semarang', 'Surabaya']
					},
					colors:['#cf0000']
				};
		
				var chart = new ApexCharts($("#bkk-truk-stats")[0], options);
				chart.render();
			}
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	

	// bkk-kereta-stats
	$.ajax({
		type: "GET",
		url: "/reports/getbranchstatsbkkbreakdown?type=kereta&startdate=" + startdate + "&enddate=" + enddate,
		success: function(data) {

			var thestats = data.bkkkereta;

			console.log(thestats);
			if (window.ApexCharts) {
				var options = {
					series: [{
						name: 'BKK Kereta',
						data: thestats
					}],
					chart: {
						type: 'bar',
						height: 320
					},
					plotOptions: {
						bar: {
							borderRadius: 4,
							borderRadiusApplication: 'end',
							horizontal: false
						}
					},
					dataLabels: {
						enabled: true
					},
					xaxis: {
						categories: ['Sidoarjo', 'Jakarta', 'Probolinggo', 'Semarang', 'Surabaya']
					},
					colors:['#cf0000']
				};
		
				var chart = new ApexCharts($("#bkk-kereta-stats")[0], options);
				chart.render();
			}
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	

	// bkk-roro-stats
	$.ajax({
		type: "GET",
		url: "/reports/getbranchstatsbkkbreakdown?type=roro&startdate=" + startdate + "&enddate=" + enddate,
		success: function(data) {

			var thestats = data.bkk_roro;

			console.log(thestats);
			if (window.ApexCharts) {
				var options = {
					series: [{
						name: 'BKK Kereta',
						data: thestats
					}],
					chart: {
						type: 'bar',
						height: 320
					},
					plotOptions: {
						bar: {
							borderRadius: 4,
							borderRadiusApplication: 'end',
							horizontal: false
						}
					},
					dataLabels: {
						enabled: true
					},
					xaxis: {
						categories: ['Sidoarjo', 'Jakarta', 'Probolinggo', 'Semarang', 'Surabaya']
					},
					colors:['#cf5000']
				};
		
				var chart = new ApexCharts($("#bkk-roro-stats")[0], options);
				chart.render();
			}
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	

	// bkk-losing-stats
	$.ajax({
		type: "GET",
		url: "/reports/getbranchstatsbkkbreakdown?type=losing&startdate=" + startdate + "&enddate=" + enddate,
		success: function(data) {

			var thestats = data.bkk_losing;

			console.log(thestats);
			if (window.ApexCharts) {
				var options = {
					series: [{
						name: 'BKK Losing',
						data: thestats
					}],
					chart: {
						type: 'bar',
						height: 320
					},
					plotOptions: {
						bar: {
							borderRadius: 4,
							borderRadiusApplication: 'end',
							horizontal: false
						}
					},
					dataLabels: {
						enabled: true
					},
					xaxis: {
						categories: ['Sidoarjo', 'Jakarta', 'Probolinggo', 'Semarang', 'Surabaya']
					},
					colors:['#cf5000']
				};
		
				var chart = new ApexCharts($("#bkk-losing-stats")[0], options);
				chart.render();
			}
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	
}

function getOmzetStats(){
 
	$.ajax({
		type: "GET",
		url: "/marketings/getomzetdata",
		success: function(data) {

			$(".loader.marketing").removeClass('d-block').addClass('d-none');

			var thestats = data;

			console.log(thestats);
			if (window.ApexCharts) {
				var options = {
					chart: {
						type: "line",
						fontFamily: 'inherit',
						height: 400,
						animations: {
							enabled: true
						},
					},
					stroke: {
						width: 4,
						curve: 'smooth' // Makes the line smooth
					},
					dataLabels: {
						enabled: false,
					},
					series: [{
						name: "Omzet",
						data: data.omzet // Data for each month
					}],
					tooltip: {
						theme: 'light',
						x: {
							formatter: function(value) {
								return value; // Keeps the month-year format in tooltip
							}
						}
					},
					grid: {
						strokeDashArray: 4,
					},
					xaxis: {
						categories: data.month_text,
						labels: {
							rotate: -45 // Rotates labels for better readability
						},
						type: 'category'
					},
					yaxis: {
						labels: {
							padding: 2
						},
					},
					colors: ['#14a714'],
					legend: {
						show: false,
					},
				};
		
				var chart = new ApexCharts($("#chart-omzet")[0], options);
				chart.render();
			}

			if (window.ApexCharts) {
				var options = {
					chart: {
						type: "line",
						fontFamily: 'inherit',
						height: 400,
						animations: {
							enabled: true
						},
					},
					stroke: {
						width: 4,
						curve: 'smooth' // Makes the line smooth
					},
					dataLabels: {
						enabled: false,
					},
					series: [{
						name: "Jumlah DO",
						data: data.event_count // Data for each month
					}],
					tooltip: {
						theme: 'light',
						x: {
							formatter: function(value) {
								return value; // Keeps the month-year format in tooltip
							}
						}
					},
					grid: {
						strokeDashArray: 4,
					},
					xaxis: {
						categories: data.month_text,
						labels: {
							rotate: -45 // Rotates labels for better readability
						},
						type: 'category'
					},
					yaxis: {
						labels: {
							padding: 2
						},
					},
					colors: ['#2a8baa'],
					legend: {
						show: false,
					},
				};
		
				var chart = new ApexCharts($("#side-chart")[0], options);
				chart.render();
			}
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	
}

function getOmzetMarketing(){
 
	$.ajax({
		type: "GET",
		url: "/marketings/getomzetdatamarketing",
		success: function(data) {

			$(".loader.marketing-u").removeClass('d-block').addClass('d-none');

			var thestats = data;

			console.log(thestats);
			if (window.ApexCharts) {
				var options = {
					chart: {
						type: "line",
						fontFamily: 'inherit',
						height: 240,
						width: 230,
						animations: {
							enabled: true
						},
					},
					stroke: {
						width: 4,
						curve: 'smooth' // Makes the line smooth
					},
					dataLabels: {
						enabled: false,
					},
					series: [{
						name: "Omzet",
						data: data.users.omzet_14 // Data for each month
					}],
					tooltip: {
						theme: 'light',
						x: {
							formatter: function(value) {
								return value; // Keeps the month-year format in tooltip
							}
						}
					},
					grid: {
						strokeDashArray: 4,
					},
					xaxis: {
						categories: data.month_text,
						labels: {
							rotate: -45 // Rotates labels for better readability
						},
						type: 'category'
					},
					yaxis: {
						labels: {
							padding: 2
						},
					},
					colors: ['#14a714'],
					legend: {
						show: false,
					},
				};
		
				var chart = new ApexCharts($("#chart-omzet-14")[0], options);
				chart.render();
			}

			if (window.ApexCharts) {
				var options = {
					chart: {
						type: "line",
						fontFamily: 'inherit',
						height: 240,
						width: 230,
						animations: {
							enabled: true
						},
					},
					stroke: {
						width: 4,
						curve: 'smooth' // Makes the line smooth
					},
					dataLabels: {
						enabled: false,
					},
					series: [{
						name: "Omzet",
						data: data.users.omzet_69 // Data for each month
					}],
					tooltip: {
						theme: 'light',
						x: {
							formatter: function(value) {
								return value; // Keeps the month-year format in tooltip
							}
						}
					},
					grid: {
						strokeDashArray: 4,
					},
					xaxis: {
						categories: data.month_text,
						labels: {
							rotate: -45 // Rotates labels for better readability
						},
						type: 'category'
					},
					yaxis: {
						labels: {
							padding: 2
						},
					},
					colors: ['#14a714'],
					legend: {
						show: false,
					},
				};
		
				var chart = new ApexCharts($("#chart-omzet-69")[0], options);
				chart.render();
			}

			if (window.ApexCharts) {
				var options = {
					chart: {
						type: "line",
						fontFamily: 'inherit',
						height: 240,
						width: 230,
						animations: {
							enabled: true
						},
					},
					stroke: {
						width: 4,
						curve: 'smooth' // Makes the line smooth
					},
					dataLabels: {
						enabled: false,
					},
					series: [{
						name: "Omzet",
						data: data.users.omzet_93 // Data for each month
					}],
					tooltip: {
						theme: 'light',
						x: {
							formatter: function(value) {
								return value; // Keeps the month-year format in tooltip
							}
						}
					},
					grid: {
						strokeDashArray: 4,
					},
					xaxis: {
						categories: data.month_text,
						labels: {
							rotate: -45 // Rotates labels for better readability
						},
						type: 'category'
					},
					yaxis: {
						labels: {
							padding: 2
						},
					},
					colors: ['#14a714'],
					legend: {
						show: false,
					},
				};
		
				var chart = new ApexCharts($("#chart-omzet-93")[0], options);
				chart.render();
			}

			if (window.ApexCharts) {
				var options = {
					chart: {
						type: "line",
						fontFamily: 'inherit',
						height: 240,
						width: 230,
						animations: {
							enabled: true
						},
					},
					stroke: {
						width: 4,
						curve: 'smooth' // Makes the line smooth
					},
					dataLabels: {
						enabled: false,
					},
					series: [{
						name: "Omzet",
						data: data.users.omzet_112 // Data for each month
					}],
					tooltip: {
						theme: 'light',
						x: {
							formatter: function(value) {
								return value; // Keeps the month-year format in tooltip
							}
						}
					},
					grid: {
						strokeDashArray: 4,
					},
					xaxis: {
						categories: data.month_text,
						labels: {
							rotate: -45 // Rotates labels for better readability
						},
						type: 'category'
					},
					yaxis: {
						labels: {
							padding: 2
						},
					},
					colors: ['#14a714'],
					legend: {
						show: false,
					},
				};
		
				var chart = new ApexCharts($("#chart-omzet-112")[0], options);
				chart.render();
			}
 
			if (window.ApexCharts) {
				var options = {
					series: data.this_month,
					chart: {
					width: 480,
					type: 'pie',
					
				  },
				  labels: ['Indra', 'Lilis', 'Finca', 'Anindya'],
				  legend: {
					position: 'bottom'
				  }
	 
				};
		
				var chart = new ApexCharts($("#pie-chart")[0], options);
				chart.render();
			}

		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});	
}

function getproductgroupnames(group_id){
	var groupname = "";
	$.ajax({
		async: false,
		type: "GET",
		url: "/productrequests/getproductgroupname/" + group_id ,
		success: function(data) {
			groupname = data.groupname;
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
	return groupname;
}

	function setGroupnames(groupname){
		return groupname;
	}

function getrangetires(group_id, vehicle_id, date){
	alert("masuk sini"); 
	$.ajax({
		type: "GET",
		url: "/productrequests/getrangetires/" + group_id + "/" + vehicle_id + "/" + date,
		success: function(data) {
			var quantity = Number(data.quantity);
			if(data.tire_target > 0){
				$('#tire_target').val(quantity);
				$('#tiretarget').removeClass('hide');
			}
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getProductByGroup()
{
	var group_id = $('#productrequest_productgroup_id').val();
	var vehicle_id = $('#productrequest_vehicle_id').val();

	var date = $('#productrequest_date').val();
	$('#tiretarget').addClass('hide');

	var groupname = getproductgroupnames(group_id);

	if (groupname.toLowerCase() == "ban"){
		getrangetires(group_id,vehicle_id, date);
	}

	var i = 0;
	$.ajax({
		type: "GET",
		url: "/productrequests/getproductbygroupid/" + group_id,
		success: function(data) {
			for(j=1;j<=10;j++)
			{
				prod = data.products;
				$('#productrequestitems_' + j).find("option").remove();
				$('#productrequestitems_' + j).append('<option value="">- Barang -</option>');
				$('#productid_' + j).val();
				$('#quantity_' + j).val(0);
				$('#stock_' + j).val(0);
				for(i=0;i<prod.length;i++)
				{
					$('#productrequestitems_' + j).append('<option value="'+ prod[i].id +'">'+ prod[i].name +'</option>');
				}	
			}	
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getProductByGroupPO()
{
	var group_id = $('#productorder_productgroupid').val();	
	
	$.ajax({
		type: "GET",
		url: "/productrequests/getproductbygroupid/" + group_id,
		success: function(data) {
			prod = data.products;
			$('#productorder_productid').find("option").remove();
			$('#productorder_productid').append('<option value="">- Barang -</option>');
			for(i=0;i<prod.length;i++)
			{
				$('#productorder_productid').append('<option value="'+ prod[i].id +'">'+ prod[i].name +'</option>');
			}	
				
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getOfficeexpensegroup()
{
	var group_id = $('#officeexpensegroupparent').val();

	$.ajax({
		type: "GET",
		url: "/officeexpenses/getofficeexpensegroup/" + group_id,
		success: function(data) {
			prod = data.group;
			
			$('#officeexpensegroupchild').find("option").remove();
			$('#officeexpensegroupchild').append('<option value="">- Group Kas -</option>');
			for(i=0;i<prod.length;i++)
			{
				$('#officeexpensegroupchild').append('<option value="'+ prod[i].id +'">'+ prod[i].name +'</option>');
			}
				
			$(".chzn-select").chosen();	
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getOfficeBankexpensegroup()
{
	var group_id = $('#bankexpensegroupparent').val();

	$.ajax({
		type: "GET",
		url: "/officeexpenses/getbankexpensegroup/" + group_id,
		success: function(data) {
			prod = data.group;
			
			$('#bankexpensegroupchild').find("option").remove();
			$('#bankexpensegroupchild').append('<option value="">- Pilih Group -</option>');
			for(i=0;i<prod.length;i++)
			{
				$('#bankexpensegroupchild').append('<option value="'+ prod[i].id +'">'+ prod[i].name +'</option>');
			}	
				
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getBankexpensegroup()
{
	var group_id = $('#bankexpensegroupparent').val();

	$.ajax({
		type: "GET",
		url: "/bankinvoices/getbankexpensegroup/" + group_id,
		success: function(data) {
			prod = data.group;
			
			$('#bankexpensegroupchild').find("option").remove();
			$('#bankexpensegroupchild').append('<option value="">- Pilih Group -</option>');
			for(i=0;i<prod.length;i++)
			{
				$('#bankexpensegroupchild').append('<option value="'+ prod[i].id +'">'+ prod[i].name +'</option>');
			}	
				
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getBankexpensegroupdebit()
{
	var group_id = $('#bankexpensegroupparentdebit').val();

	$.ajax({
		type: "GET",
		url: "/bankexpenses/getbankexpensegroupdebit/" + group_id,
		success: function(data) {
			prod = data.group;
			
			$('#bankexpensegroupchilddebit').find("option").remove();
			$('#bankexpensegroupchilddebit').append('<option value="">- Pilih Group -</option>');
			for(i=0;i<prod.length;i++)
			{
				$('#bankexpensegroupchilddebit').append('<option value="'+ prod[i].id +'">'+ prod[i].name +'</option>');
			}	
				
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getBankexpensegroupcredit()
{
	var group_id = $('#bankexpensegroupparentcredit').val();

	$.ajax({
		type: "GET",
		url: "/bankexpenses/getbankexpensegroupcredit/" + group_id,
		success: function(data) {
			prod = data.group;
			
			$('#bankexpensegroupchildcredit').find("option").remove();
			$('#bankexpensegroupchildcredit').append('<option value="">- Pilih Group -</option>');
			for(i=0;i<prod.length;i++)
			{
				$('#bankexpensegroupchildcredit').append('<option value="'+ prod[i].id +'">'+ prod[i].name +'</option>');
			}	
				
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function getProductByIdPO(){
	var product_id = $('#productorder_productid').val();
	$.ajax({
		type: "GET",
		url: "/productorders/getproductbyid/" + product_id,
		success: function(data) {
			prod = data.product;
			$('#productorder_unitname').val(prod.unit_name);
			$('#productorder_priceper').val(parseInt(prod.unit_price));

			changeTotalOrderPO();
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}


function getTaxInvoiceCustomerbyDate(){
	/*unused function since filter applied to table */
	var date = $('#taxinvoiceitems_date').val();
	$('#customer-search').hide();
	$("#lblWarning").hide();
	$("#content").hide();
	$.ajax({
	type: "GET",
	url: "/taxinvoiceitems/getCustomerbyDate/" + date,
	success: function(data) {
		prod = data.customer;
		if(prod.length == 0)
		{
			$("#lblWarning").html("Maaf data Surat Jalan untuk tanggal "+ date + " kosong.")
			$("#lblWarning").show();
		}
		else{
			$('#customer-search').show();
			$('#customer_id').find("option").remove();
			$('#customer_id').append('<option value="">- Pelanggan -</option>');
			for(i=0;i<prod.length;i++)
			{
				$('#customer_id').append('<option value="'+ prod[i].id +'">'+ prod[i].name +'</option>');
			}	

		}
	},
	failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function changeTotalOrderPO()
{
	var quantity = $('#productorder_quantity').val().replace(',','.');
	var priceper = $('#productorder_priceper').val();
	
	var subtotal = Number(quantity) * Number(priceper.split('.').join(''));

	$('#productorder_total').val(subtotal.formatMoney(0,',','.'));
}

function togglePremiCheckbox()
{
	if ($('#is_premi').prop('checked')) {
		$('#div_description').hide();
		$('#div_totalbonus').show();
	}else{
		$('#div_description').show();
		$('#div_totalbonus').hide();
	}
}

function toggleVendorCheckbox()
{
	if ($('#by_vendor').prop('checked')) {
		$('#div_vendor').show();
	}else{
		$('#div_vendor').hide();
	}
}

function getAllowanceInvoiceAdd()
{
	var quantity = Number($('#invoice_quantity').val());
	var tol_single = Number($('#invoice_tol_single').val());
	var driver_single = Number($('#invoice_driver_single').val());
	var helper_single = Number($('#invoice_helper_single').val());
	var gas_single = Number($('#invoice_gas_single').val());
	var misc_single = Number($('#invoice_misc_single').val());

	var tol_fee = quantity * tol_single;
	var driver_allowance = quantity * driver_single;
	var misc_allowance = quantity * misc_single;
	var gas_allowance = quantity * gas_single;
	var helper_allowance = quantity * helper_single;
	
	var total = tol_fee + driver_allowance + gas_allowance + misc_allowance + helper_allowance;

	$('#invoice_driver').val(driver_allowance.formatMoney(0,',','.'));
	$('#invoice_helper').val(helper_allowance.formatMoney(0,',','.'));
	$('#invoice_misc').val(misc_allowance.formatMoney(0,',','.'));
	$('#invoice_tol_fee').val(tol_fee.formatMoney(0,',','.'));
	$('#invoice_gas').val(gas_allowance.formatMoney(0,',','.'));
	$('#invoice_total').val(total.formatMoney(0,',','.'));
}

function hideAllSubs()
{
	$(".submenu").hide(); 
	$('.submenu').removeClass('on');
}

function toggleSub(id) 
{
	var submenu = $('#sub-' + id);
	if (submenu.length > 0) {		
		if (submenu.hasClass('on')) {
			submenu.toggle();
			submenu.removeClass('on');
		}
		else {
			hideAllSubs();
			
			submenu.addClass('on');
			if (submenu.hasClass('two-column-list')) {
				submenu.css("display", "grid");
			} else {
				submenu.show();
			}
		}
	}
}

function getDriverforDriverExpense()
{
	var type = $('#type_driver').val();

	if(type.length > 0){
		$.ajax({
			type: "GET",
			url: "/driverexpenses/getdrivers/" + type,
			success: function(data) {
				$('#div-driver').html(data.html);
			},
			failure: function() {alert("Error. Mohon refresh browser Anda.");}
		});	
	}
}

function countTotalDriverExpense()
{
	var weightloss = Number($('#driverexpense_weight_loss').val());
	var accident = Number($('#driverexpense_accident').val());
	var sparepart = Number($('#driverexpense_sparepart').val());
	var bon = Number($('#driverexpense_bon').val());

	var total = weightloss + accident + sparepart + bon;

	$('#driverexpense_total').val(total.formatMoney(0,',','.'));
}

function getDriverforPayroll()
{
	var type = $('#type_driver').val();

	if (type == "h")
		$('.row-helper').addClass('hide');
	else
		$('.row-helper').removeClass('hide');


	if(type.length > 0){
		$.ajax({
			type: "GET",
			url: "/payrolls/getdrivers/" + type,
			success: function(data) {
				$('#div-driver').html(data.html);
			},
			failure: function() {alert("Error. Mohon refresh browser Anda.");}
		});	
	}
}

function getDriverDataMaster()
{
	var	type = $('#type_driver').val();
	var id = $('#driver_id').val();

	if(type.length >0 && id.length > 0){
		$.ajax({
			type: "GET",
			url: "/payrolls/getdriverdata/" + type + "/" + id,
			success: function(data) {

				$('#lblNonHolidaysFare').html(data.non_holiday_fare);
				$('#lblHolidaysFare').html(data.holiday_fare);
				$('#lblMasterWeightLoss').html(data.weight_loss);
				$('#lblMasterAccident').html(data.accident);
				$('#lblMasterSparepart').html(data.sparepart);
				$('#lblMasterBon').html(data.bon);
				$('#lblMasterSaving').html(data.saving);

				countPayrollDriverExpense();
			},
			failure: function() {alert("Error. Mohon refresh browser Anda.");}
		});	
	}
}

function countPayrollDriverExpense()
{
	var holidays = Number($('#payroll_holidays').val());
	var non_holidays = Number($('#payroll_non_holidays').val());

	if(holidays + non_holidays > 31)
	{
		alert("Jumlah HLN dan Non HLN tidak boleh melebihi 31 hari")
	}else{
		var holidays_payment = holidays * Number($('#lblHolidaysFare').html().split('.').join(''));
		$('#lblHolidays').html(holidays.formatMoney(0,',','.'));
		$('#lblHolidaysPayment').html(holidays_payment.formatMoney(0,',','.'));

		var non_holidays_payment = non_holidays * Number($('#lblNonHolidaysFare').html().split('.').join(''));
		$('#lblNonHolidays').html(non_holidays.formatMoney(0,',','.'));
		$('#lblNonHolidaysPayment').html(non_holidays_payment.formatMoney(0,',','.'));

		var saving_reduction = Number($('#payroll_saving_reduction').val());
		var saving_red = Number($('#lblMasterSaving').html().split('.').join('')) - saving_reduction;
		$('#lblSavingReduction').html(saving_reduction.formatMoney(0,',','.'));
		$('#lblSavingReduction2').html(saving_reduction.formatMoney(0,',','.'));
		$('#lblSavingRed').html(saving_red.formatMoney(0,',','.'));
		$('#lblSavingRed2').html(saving_red.formatMoney(0,',','.'));

		var bonus = Number($('#payroll_bonus').val());
		$('#lblBonus').html(bonus.formatMoney(0,',','.'));

		var helper_fee = Number($('#payroll_helper_fee').val());
		$('#lblHelperFee').html(helper_fee.formatMoney(0,',','.'));

		var income_total = holidays_payment + non_holidays_payment + saving_reduction + bonus + helper_fee;
		$('#lblTotalPayment').html(income_total.formatMoney(0,',','.'));

		var weightloss = Number($('#payroll_weight_loss').val());
		var totalweightloss = Number($('#lblMasterWeightLoss').html().split('.').join('')) - weightloss;
		$('#lblPayrollWeightLoss').html(weightloss.formatMoney(0,',','.'));
		$('#lblTotalWeightLoss').html(totalweightloss.formatMoney(0,',','.'));

		var accident = Number($('#payroll_accident').val());
		var totalaccident = Number($('#lblMasterAccident').html().split('.').join('')) - accident;
		$('#lblPayrollAccident').html(accident.formatMoney(0,',','.'));
		$('#lblTotalAccident').html(totalaccident.formatMoney(0,',','.'));

		var sparepart = Number($('#payroll_sparepart').val());
		var totalsparepart = Number($('#lblMasterSparepart').html().split('.').join('')) - sparepart;
		$('#lblPayrollSparepart').html(sparepart.formatMoney(0,',','.'));
		$('#lblTotalSparepart').html(totalsparepart.formatMoney(0,',','.'));

		var bon = Number($('#payroll_bon').val());
		var totalbon = Number($('#lblMasterBon').html().split('.').join('')) - bon;
		$('#lblPayrollBon').html(bon.formatMoney(0,',','.'));
		$('#lblTotalBon').html(totalbon.formatMoney(0,',','.'));

		var allowance = Number($('#payroll_allowance').val());
		$('#lblPayrollAllowance').html(allowance.formatMoney(0,',','.'));

		var saving = Number($('#payroll_saving').val());
		var totalsaving = Number($('#lblSavingRed2').html().split('.').join('')) + saving;
		$('#lblPayrollSaving').html(saving.formatMoney(0,',','.'));
		$('#lblTotalSaving').html(totalsaving.formatMoney(0,',','.'));

		var expense_total = weightloss + accident + sparepart + bon + saving + allowance;
		$('#lblPayrollExpenseTotal').html(expense_total.formatMoney(0,',','.'));
		

		var total = income_total - expense_total;
		$('#payroll_total').val(total.formatMoney(0,',','.'));
		$('#lblPayrollTotal').html(total.formatMoney(0,',','.'));
		$('#lblPayrollTotal').removeAttr('class');

		if(total >= 0)
		{
			$('#lblPayrollTotal').attr('class', 'right green');
		}
		else
		{
			$('#lblPayrollTotal').attr('class', 'right red');
		}
	}
}

function checkAllKas(){
	var checked = false;

	if ($('#checkallkas').prop('checked')){
		checked = true;
	}
	
	$(":input[name^='filterform[Kas_']").each(function() {
       $(this).attr('checked', checked);
    });
}

function checkAllBank(){
	var checked = false;

	if ($('#checkallbank').prop('checked')){
		checked = true;
	}
	
	$(":input[name^='filterform[Bank_']").each(function() {
       $(this).attr('checked', checked);
    });
}

function countTotalAssetOrder(){
	var unit_price = $('#assetorder_unit_price').val().split('.').join('').replace(',','.');
	var quantity = $('#assetorder_quantity').val();

	if(unit_price != '' && quantity != ''){
		var total = Number(unit_price) * Number(quantity);

		$('#assetorder_total').val(total.formatMoney(2,',','.'));
	}
}

function countTotalClaim(){

	const invoicetrain = document.querySelector('.train') !== null;

	var claimmemo_shrink = $('#claimmemo_shrink').val();
	var claimmemo_weight_gross = $('#claimmemo_weight_gross').val();
	var shrink_tolerance_percent = $('#claimmemo_shrink_tolerance_percent').val();
	var discount_amount = $('#claimmemo_discount_amount').val();
	// var claimmemo_tolerance_total = $('#claimmemo_shrink_tolerance_percent').val();

	if(claimmemo_weight_gross != '' && shrink_tolerance_percent != ''){
		var tolerance_total = claimmemo_weight_gross * (shrink_tolerance_percent / 100)
		$('#claimmemo_tolerance_total').val(Math.floor(tolerance_total));
		console.log(tolerance_total);

		var shrinkage_load = claimmemo_shrink - Math.floor(tolerance_total)
		$('#claimmemo_shrinkage_load').val(shrinkage_load);
	}

	var price_per = $('#claimmemo_price_per').val().split('.').join('').replace(',','.');
	var quantity = $('#claimmemo_shrinkage_load').val();

	if(price_per != '' && quantity != ''){

		if (invoicetrain){
			var total = Number(price_per) * Number(quantity) / 2;
		} else {
			var total = Number(price_per) * Number(quantity);
		}

		if(discount_amount != '' && discount_amount > 0){
			total = total - Number(discount_amount);
		}

		$('#claimmemo_total').val(total);
		$('#claimmemo_total_text').html(total.formatMoney(0,',','.'));
	}
}

function submitFormFilter()
{
	var form = $('#filterform');
	form.submit();
}

$(document).ready(function() {
	var T_WIDTH = $('#sliding_window').width();
	var selected = curr = 1;
	var slide = 0;

	// default tab
	var h = location.hash;
	if (h.length) {
		selected = h.substr(1);
		slide = (selected-curr) * T_WIDTH;
		slide = "-=" + slide
		
		$('.sliding_container').animate({left: slide + "px"}, 0, "easeInOutQuint");
				
		$('#tabbed li').removeClass('current');
		$('#link_'+selected).parent().addClass('current');
		curr = selected;

	} else {
		$('#link_1').parent().addClass('current');
	}

	// clear submenus
	$('#main, #footer, #nav').click(function(e) {hideAllSubs();});

	// slide Tabs
	$('#tabbed a').click(function(e){
		selected = ($(this).attr('id').substr(5));

		if (selected > curr) {
			slide = (selected-curr) * T_WIDTH;
			slide = "-=" + slide
		} else {
			slide = (curr-selected) * T_WIDTH;
			slide = "+=" + slide
		}

		$('.sliding_container').animate({left: slide + "px"}, 0, "easeInOutQuint"); 
				
		$('#tabbed li').removeClass('current');
		$(this).parent().addClass('current');
		curr = selected;
		
		return false;
	});	

	$("input:radio[name='invoice[cargo_type]']").change(function(){  
		if(this.value == 'padat' && this.checked){
 
			var cargotype = 'padat'
			$.ajax({
				type: "GET",
				url: "/invoices/gettanktype/" + cargotype,
				success: function(data) {
					$('#div_tanktype').html(data.html);
					$(".chzn-select").chosen();
				},
				failure: function() {alert("Error. Mohon refresh browser Anda.");}
			});		
	
		}else{

			var cargotype = 'cair'
			$.ajax({
				type: "GET",
				url: "/invoices/gettanktype/" + cargotype,
				success: function(data) {
					$('#div_tanktype').html(data.html);
					$(".chzn-select").chosen();
				},
				failure: function() {alert("Error. Mohon refresh browser Anda.");}
			});
		}
	});

	$("input:radio[name='event[invoicetrain]']").change(function(){  
	if(this.value == 'true' && this.checked){
		$("#div_opstrains").show();
		$("#div_routetrains").show();
		$("#div_stationtrains").show();
	}else{
		$("#div_opstrains").hide();
		$("#div_routetrains").hide();
		$("#div_stationtrains").hide();
	}
	});

	$("#invoice_transporttype").change(function(){
	if($(this).val() == 'KAPAL (TOL LAUT)'){ 
		$("#ship_field").show();
		$("#port_field").show();
	} else {
		$("#ship_field").hide();
		$("#port_field").hide();
	}
	}); 

	$('#event_submit').live('click', function(e) {
		e.preventDefault();

		var errors = "";
		var form = $(this).closest("form");

		if ($('#event_customer_id').val() == 0) {			
			errors = addComma(errors, "<strong>Pelanggan</strong>");
		}

		if ($('#event_commodity_id').val() == 0) {			
			errors = addComma(errors, "<strong>Komoditas</strong>");
		}

		if (errors == "") {
			form.submit();
		}
		else {
			errors = "Harap mengisi data:<br>" + errors;
			showMessageBox(errors, 2500);
		}
	});

	$('#invoice_submit').live('click', function(e) {
		e.preventDefault();

		//enabled form field
		$("#invoice_office_id").prop('disabled',false);
		$("#invoice_operator_id").prop('disabled',false);
		$("#invoice_route_id").prop('disabled',false);
		$("#invoice_routetrain_id").prop('disabled',false);

		var errors = "";
		var form = $(this).closest("form");

		if($('#invoice_kosongan').val() == false || $('#invoice_kosongan').length == 0 ){
			if ($('#invoice_event_id').val() == 0 || $('#invoice_event_id').val() == '')  {			
				errors = addComma(errors, "<strong>Nomor DO</strong>");
			}
		} else {
			if ($('#sku_id').val() == '' || $('#load_date').val() == '' || $('#unload_date').val() == '' || $('#weight_gross').val() == '' || $('#weight_net').val() == '') {
				errors = addComma(errors, "<strong>Data Surat Jalan</strong>");
			}
		}

		if ($('#invoice_office_id').val() == 0) {
			errors = addComma(errors, "<strong>Kantor</strong>");
		}

		if ($('#invoice_customer_id').val() == 0) {			
			errors = addComma(errors, "<strong>Pelanggan</strong>");
		}

		if ($('#invoice_route_id').val() == 0) {			
			errors = addComma(errors, "<strong>Jurusan</strong>");
		}
		
		if ($('#invoice_vehicle_id').val() == 0) {			
			errors = addComma(errors, "<strong>Kendaraan</strong>");
		}

		if ($('#invoice_driver_id').val() == 0)  {			
			errors = addComma(errors, "<strong>Supir</strong>");
		}

		var tanktype_name = $('#invoice_tanktype').val()

		if (tanktype_name == 'ISOTANK') {
			if ($('#invoice_isotank_id').val() == 0)  {			
				errors = addComma(errors, "<strong>Isotank</strong>");
			}
		} else if (tanktype_name == 'DRY CONTAINER 20FT' || tanktype_name == 'DRY CONTAINER 40FT' || tanktype_name == 'SIDE DOOR CONTAINER 20FT' || tanktype_name == 'SIDE DOOR CONTAINER 40FT' || tanktype_name == 'KONTAINER STANDART' || tanktype_name == 'KONTAINER 20FT' || tanktype_name == 'KONTAINER 40FT' || tanktype_name == 'KONTAINER SIDE DOOR') {
			if ($('#invoice_container_id').val() == 0)  {			
				errors = addComma(errors, "<strong>Kontainer</strong>");
			}
		}

		if (errors == "") {
			form.submit();
		}
		else {
			errors = "Harap mengisi data:<br>" + errors;
			showMessageBox(errors, 2500);
		}
	});

	$('#invoice_submit_gas').live('click', function(e) {
		e.preventDefault();

		var errors = "";
		var form = $(this).closest("form");

		//if (parseInt($('#invoice_gas_litre').val()) < 0) {			
		//	errors = addComma(errors, "<strong>Solar</strong>: Nominal tidak boleh minus.");
		//}

		if (errors == "") {
			form.submit();
		}
		else {
			errors = "Data error:<br>" + errors;
			showMessageBox(errors, 2500);
		}
	});		

	$('#invoicereturn_submit').live('click', function(e) {
		e.preventDefault();

		var errors = "";
		var form = $(this).closest("form");

		var driver_allowance = $('#invoicereturn_driver_allowance').val();
		var max_allowance = $('#invoicereturn_max_allowance').val();
		if (Number(driver_allowance) > Number(max_allowance)) {
			$('#invoicereturn_driver_allowance').val(max_allowance);
			showMessageBox('Sangu tidak boleh melebihi total Rp. ' + max_allowance, 2500)
		}
		else {			
			form.submit();
		}
	});

	$('#invoice_customer_id').live('change', function(e) {
		e.preventDefault();
		resetAllowances();
		customer_id = $(this).attr('value');
		if (customer_id == '') customer_id = -1;
		getRoutes(customer_id);
		// getRoutesWithTransportType(customer_id);
	});

	$('#invoice_customer_id_new').live('change', function(e) {
		e.preventDefault();
		resetAllowances();
		customer_id = $(this).attr('value');
		if (customer_id == '') customer_id = -1;
		// getRoutes(customer_id);
		getRoutesWithTransportType(customer_id);
	});	

	$('#officeexpense_submit').live('click', function(e) {
		e.preventDefault();

		var errors = "";
		var form = $(this).closest("form");

		if ($('#officeexpensegroupparent').val() == "1" && $('#vehicle_id').val() == "") {			
			errors = addComma(errors, "<strong>Kendaraan</strong>");
		}
		
		if($('#officeexpensegroupparent').val() != "" && $('#officeexpensegroupchild').val() == ""){
			errors = addComma(errors, "<strong>Group Kas</strong>");
		}

		if (errors == "") {
			form.submit();
		}
		else {
			errors = "Harap mengisi data:<br>" + errors;
			showMessageBox(errors, 2500);
		}
	});

	$('#driverexpense_submit').live('click', function(e) {
		e.preventDefault();

		var errors = "";
		var form = $(this).closest("form");

		if ($('#driver_id').val() == "") {			
			errors = addComma(errors, "<strong>Supir</strong>");
		}
		
		if (errors == "") {
			form.submit();
		}
		else {
			errors = "Harap mengisi data:<br>" + errors;
			showMessageBox(errors, 2500);
		}
	});

	$('#paymentcheck_submit').live('click', function(e) {
		e.preventDefault();

		var errors = "";
		var form = $(this).closest("form");

		if ($('#paymentcheck_check_no').val() == "") {			
			errors = addComma(errors, "<strong>No. Giro</strong>");
		}

		if (Number($('#txt_total').html().split('.').join('')) == 0) {			
			errors = addComma(errors, "<strong>Order Pembelian</strong>");
		}

		if (errors == "") {
			form.submit();
		}
		else {
			errors = "Harap mengisi data:<br>" + errors;
			showMessageBox(errors, 2500);
		}
	});	

	$('#vehiclelog_submit').live('click', function(e) {
		e.preventDefault();

		var errors = "";
		var form = $(this).closest("form");

		if ($('#vehiclelog_description').val() == "") {
			errors = addComma(errors, "<strong>Keterangan</strong>");
		}
		
		if (errors == "") {
			form.submit();
		}
		else {
			errors = "Harap mengisi data:<br>" + errors;
			showMessageBox(errors, 2500);
		}
	});

	$('#driverlog_submit').live('click', function(e) {
		e.preventDefault();

		var errors = "";
		var form = $(this).closest("form");

		if ($('#driverlog_description').val() == "") {
			errors = addComma(errors, "<strong>Keterangan</strong>");
		}
		
		if (errors == "") {
			form.submit();
		}
		else {
			errors = "Harap mengisi data:<br>" + errors;
			showMessageBox(errors, 2500);
		}
	});

	$('#user_submit').live('click', function(e) {
		e.preventDefault();

		var errors = "";
		var form = $(this).closest("form");

		if ($('#user_username').val() == "") {
			errors = addComma(errors, "<strong>Username</strong>");
		}

		if ($('#user_email').val() == "") {
			errors = addComma(errors, "<strong>Email</strong>");
		}

		if ($('#user_password').val() == "" && $('#process').val() == "") {
			errors = addComma(errors, "<strong>Password</strong>");
		}

		if ($('#user_password').val() != "" && $('#user_password').val().length < 6) {
			errors = addComma(errors, "<strong>Password minimal 6 huruf</strong>");
		}
		
		if (errors == "") {
			form.submit();
		}
		else {
			errors = "Harap mengisi data:<br>" + errors;
			showMessageBox(errors, 2500);
		}
	});

	$('#invoicereturnadd_submit').live('click', function(e) {
		e.preventDefault();

		var errors = "";
		var form = $(this).closest("form");
		var samedate = false;

		if($('#tableInvoicereturns').length > 0){
			$('#tableInvoicereturns > tbody > tr').each(function() {
				id = $(this).attr("id");
				if($('#date_' + id).html() == $('#invoicereturn_date').val()){
					samedate = true;
				}
			});
		}

		if (samedate == true) {
			errors = addComma(errors, "<strong>Tanggal BKM Tambahan tidak boleh sama dengan tanggal BKM sebelumnya</strong>");
		}
		
		if (errors == "") {
			form.submit();
		}
		else {
			errors = "Harap mengisi data:<br>" + errors;
			showMessageBox(errors, 2500);
		}
	});

	$(".chzn-select").chosen();

	if ($('.tablesorterFilters').length > 0) {
		$('.tablesorter').tablesorter({
			cssInfoBlock : "tablesorter-no-sort",
			widgets: ['filter'],
			widgetOptions : {
				filter_columnFilters : true
			}
		});
	}
	else {
		$('.tablesorter').tablesorter();
	}
	
	$('.tipsy').tipsy({gravity:'s'});

	$('.date-picker').datepicker({"dateFormat" : "dd-mm-yy", changeMonth : true, changeYear : true});

	if ($('#flash').length > 0) {
		showMessageBox($('#flash').html(), 2500);
	}

	$('#msg-box .btn-close').bind('click tap', function(e) {
		e.preventDefault();
		$('#msg-box').fadeOut();
	});

	// $('#cashier-ref').bind('click tap', function(e) {
	// 	e.preventDefault();
	// 	getCashierRequests();		
	// });		
	
	if ($('#cashier-requests').length > 0) {
		getCashierRequests();
		setInterval('getCashierRequests()', 600000);
	}

	if ($('#calendar').length > 0) {
		getDataEvents($('#calendar').attr('class'));
	}

	if ($('#calendar2').length > 0) {
		getDataEvents2($('#calendar2').attr('class'));
		setInterval(function() {
			getDataEvents2($('#calendar2').attr('class'));
		}, 600000);
	}

	if ($('#calendarBookings').length > 0) {
		getDataBookings($('#calendarBookings').attr('class'));
	}

	if ($('#chartincomevehicle').length > 0) {
		getGraphIncomeVehicle();
	}

	if($('#chartexpensevehicle').length > 0){
		getGraphExpenseVehicle();
	}

	if($('#chartcustomer').length > 0){
		getGraphCustomer();
	}

	if($('#customers-stats').length > 0){
		getBranchStats();
	}

	if($('#chart-omzet').length > 0){
		getOmzetStats();
		getOmzetMarketing();
	}

	if($('#div_annualvehiclegraph').length > 0){
		getGraphAnnualReportVehicle();
	}

	//calculate distance
	$(document).on('click', '#calculateDistance', function(e) {
		e.preventDefault();

		alert('Melakukan kalkulasi jarak (km).');

		var longitudeStart = $("#quotation_longitude_start").val();
		var latitudeStart = $("#quotation_latitude_start").val();
		var longitudeEnd = $("#quotation_longitude_end").val();
		var latitudeEnd = $("#quotation_latitude_end").val();

		var distanceKm = $("quotation_distance").val();

		if (!longitudeStart || !latitudeStart || !longitudeEnd || !latitudeEnd) {

			alert("Data Longitude dan Latitude peta harus terisi.");
			e.preventDefault(); // Stop form submission

		} else {

			// Construct dynamic URL without backticks
			var url = "/routelocations/checkDistance?latitude_start=" + latitudeStart +
					"&longitude_start=" + longitudeStart +
					"&latitude_end=" + latitudeEnd +
					"&longitude_end=" + longitudeEnd;

			$.ajax({
				type: "GET",
				url: url,
				success: function(data) {
					alert('Estimasi jarak: ' + data.distance_km + ' km');
					console.log(data.distance_km + ' km');
					$("#quotation_distance").val(data.distance_km).focus();
				},
				failure: function() {
					alert("Error. Mohon refresh browser Anda.");
				}
			});

		}
	});

	//calculate distance on master jurusan
	$(document).on('click', '#calculateDistanceOnRoute', function(e) {
		e.preventDefault();

		alert('Melakukan kalkulasi jarak (km).');

		var longitudeStart = $("#routelocation_longitude_start").val();
		var latitudeStart = $("#routelocation_latitude_start").val();
		var longitudeEnd = $("#routelocation_longitude_end").val();
		var latitudeEnd = $("#routelocation_latitude_end").val();

		var distanceKm = $("route_distance").val();

		if (!longitudeStart || !latitudeStart || !longitudeEnd || !latitudeEnd) {

			alert("Data Longitude dan Latitude peta harus terisi.");
			e.preventDefault(); // Stop form submission

		} else {

			// Construct dynamic URL without backticks
			var url = "/routelocations/checkDistance?latitude_start=" + latitudeStart +
					"&longitude_start=" + longitudeStart +
					"&latitude_end=" + latitudeEnd +
					"&longitude_end=" + longitudeEnd;

			$.ajax({
				type: "GET",
				url: url,
				success: function(data) {
					alert('Estimasi jarak: ' + data.distance_km + ' km');
					console.log(data.distance_km + ' km');
					$("#route_distance_field").val(data.distance_km);
				},
				failure: function() {
					alert("Error. Mohon refresh browser Anda.");
				}
			});

		}
	});

	if ($('.vehicle_autocomplete').length > 0){
		// $( ".vehicle_autocomplete" ).autocomplete({
  //     source: '/taxinvoices/generic-vehicles'});
		$.ajax({
			type: "GET",
			url: "/taxinvoices/generic-vehicles",
			success: function(data) {
				$( ".vehicle_autocomplete" ).autocomplete({
			      source: data.vehicle});
			},
			failure: function() {alert("Error. Mohon refresh browser Anda.");}
		});
	}

	if (($('#bkk-print').length > 0) || ($('#order-print').length > 0) || ($('#premi-print').length > 0) || ($('#payroll-print').length > 0)) {
		jZebra(); //init jZebra applet

		if ($('#bkk_printmatrix').length > 0) { $('#bkk_printmatrix').hide(); }
		if ($('#order_printmatrix').length > 0) { $('#order_printmatrix').hide(); }
		if ($('#premi_printmatrix').length > 0) { $('#premi_printmatrix').hide(); }
		if ($('#payroll_printmatrix').length > 0) { $('#payroll_printmatrix').hide(); }

		try 
		{
			applet = document.jzebra;
	 		if (applet != null) {
	    		// Searches for locally installed printer with "zebra" in the name
	    		applet.findPrinter("\\{dummy printer name for listing\\}");
	 		}

			monitorFinding();
	   	
	   	}
		catch(err)
		{
			
		}
	}

});

$(function ()
{
	$('.toggle-deleted').on('change', function() { $(this).is(':checked') ? $('tr.deleted').show() : $('tr.deleted').hide(); });
});


$('#event_need_vendor').on('click', function(){                  
  $('#event_vendor_name').attr('disabled', !$(this).is(':checked'));   
});

function bulatkan() {
	countTotalTaxInvoiceItems();
	changeTaxes()
}

function bulatkan_generic(){
	console.log("a");
	countTotalInvoiceGenericItems();
}

$(".is_isotank").change(function(){
	if ($(this).val() == 'false') {
		$('#invoice_isotank_id').val('').trigger('chosen:updated');
		$("#invoice_isotank_id").trigger("liszt:updated");
		// $("#phone_driver").val(null)
		$(".isotank_id").hide();
	}else{
		$(".isotank_id").show();
	}
});

if ($('#invoice_cargo_type_padat').length > 0) {
	var cargotype = 'padat'
	$.ajax({
		type: "GET",
		url: "/invoices/gettanktype/" + cargotype,
		success: function(data) {
			$('#div_tanktype').html(data.html);
			$(".chzn-select").chosen();
		},
		failure: function() {alert("Error. Mohon refresh browser Anda.");}
	});
}

function checkTank(name) {
	if (name == 'ISOTANK') {
        $(".isotank_id").show();
		$(".container_id").hide();
		// alert('iso');
        
	}else if (name == 'KONTAINER STANDART' || name == 'KONTAINER OPENSIDE') {
        $(".isotank_id").hide();
		$(".container_id").show();
		// alert('cont');
        
	}else{
		$('#invoice_isotank_id').val('').trigger('chosen:updated');
		$("#invoice_isotank_id").trigger("liszt:updated");
        $(".isotank_id").hide();
        $('#invoice_container_id').val('').trigger('chosen:updated');
		$("#invoice_container_id").trigger("liszt:updated");
		// $("#phone_driver").val(null)
		$(".container_id").hide();
		// alert('others');
	}
}

$("#invoice_tanktype").change(function(){
	if ($(this).val() == 'ISOTANK') {
        $(".isotank_id").show();
		$(".container_id").hide();
        
	}else if ($(this).val() == 'KONTAINER') {
        $(".isotank_id").hide();
		$(".container_id").show();
        
	}else{
		$('#invoice_isotank_id').val('').trigger('chosen:updated');
		$("#invoice_isotank_id").trigger("liszt:updated");
        $(".isotank_id").hide();
        $('#invoice_container_id').val('').trigger('chosen:updated');
		$("#invoice_container_id").trigger("liszt:updated");
		// $("#phone_driver").val(null)
		$(".container_id").hide();
	}
})
;
$(document).ready(function(e){
	
})
.on("click",".btn-edit-tax",function(e){
	e.preventDefault();
	var ppn = Number($('#ppn').val());
	$(".ppn11").val(ppn);
	$("#ppn-label").text(ppn);
	$("#taxinvoice_long_id").text($(this).data("long-id"));
	$("#taxinvoice_customer_name").text($(this).data("customer"));
	$("#taxinvoice_date").text($(this).data("date"));
	$("#invoice_long_id").text($(this).data("code"));
	$("#taxinvoice_description").text($(this).data("description"));
	$("#taxinvoice_remarks").text($(this).data("remarks"));
	$("#taxinvoice_insurance_cost").val($(this).data("insurance-cost"));
	$("#taxinvoice_claim_cost").val($(this).data("claim-cost"));
	
	$("#txt_claim_cost").text();
	$("#txt_insurance_cost").text();
	$("#txt_extra_cost").text();

	if($("#txt_dp_cost").length > 0){
		$("#txt_dp_cost").text();
	}
	
	$("#txt_gst_tax").text();
	$("#txt_price_tax").text();
	$("#txt_claim").text();
	$("#txt_total").text();
	$("#lbl_subtotal").text($(this).data("subtotal").formatMoney(2,',','.'));
	$("#txt_extra_cost").text($(this).data("extra-cost").formatMoney(2,',','.'));
	
	if($("#txt_dp_cost").length > 0){
		$("#txt_dp_cost").text($(this).data("dp-cost").formatMoney(2,',','.'));
	}

	// $("#txt_claim").text($(this).data("claim").formatMoney(2,',','.'));
	
	$("#taxinvoice_id").val($(this).data("id"));

	gst_tax = $(this).data("gst-tax");
	gst_percentage = $(this).data("gst-percentage");
	price_tax = $(this).data("price-tax");
	$("#chk_gst_tax").removeAttr("checked");
	$("#chk_price_tax").removeAttr("checked");

	console.log(gst_percentage);

	if ((parseFloat(gst_tax) > 0 && parseFloat(gst_percentage) == 0) || parseFloat(gst_percentage) == ppn ) {
		$(".ppn11").attr("checked","checked");
		if (parseFloat(gst_percentage) > 0) {
			$(".ppn11").val(gst_percentage);
			$("#ppn-label").text(parseFloat(gst_percentage));
		}
		// else 

		$("#ppn_amount").text(ppn);
		$("#ppn-row").show();
	}
	// else if(parseFloat(gst_percentage) == 1.1){
	// 	$(".ppn1-1").attr("checked","checked");
	// 	$("#ppn_amount").text("1,1");
	// 	$("#ppn-row").show();
	// }else{
	// 	$(".no-ppn").attr("checked","checked");
	// 	$("#ppn-row").hide();
	// 	// $("#ppn_amount").text(ppn);
	// } 
	else if(parseFloat(gst_percentage) == 10){
		$(".ppn10").attr("checked","checked");
		$(".ppn10").val(gst_percentage);
		$("#ppn-label").text(parseFloat(gst_percentage));
	}
	else if(parseFloat(gst_percentage) == 1.1){
		$(".ppn1-1").attr("checked","checked");
		$(".ppn1-1").val(gst_percentage);
		$("#ppn-label").text(parseFloat(gst_percentage));
	}else if(parseFloat(gst_percentage) == 1){
		$(".ppn1").attr("checked","checked");
		$(".ppn1").val(gst_percentage);
		$("#ppn-label").text(parseFloat(gst_percentage));
	}else{
		$(".ppn11").attr("checked","checked");
		$(".no-ppn").attr("checked","checked");
		$("#ppn-row").hide();
	} 
	
	console.table({
		gst_tax: parseFloat(gst_tax),
		gst_percentage: parseFloat(gst_percentage)
	});
	if (parseFloat(price_tax) > 0) {
		$("#chk_price_tax").attr("checked","checked");
	}


	$("#taxinvoice_subtotal").val($(this).data("subtotal"));
	$("#taxinvoice_extra_cost").val($(this).data("extra-cost"));
	$("#taxinvoice_dp_cost").val($(this).data("dp-cost"));
	$("#taxinvoice_claim").val($(this).data("claim"));

	changeTaxes();
	$('#sentdate').datepicker("destroy");
	$('#sentdate').val($(this).data("sentdate"));
	$('#sentdate').datepicker({"dateFormat" : "dd-mm-yy", changeMonth : true, changeYear : true});
	$('#confirmeddate').val($(this).data("confirmeddate"));
	$('#confirmeddate').datepicker({"dateFormat" : "dd-mm-yy", changeMonth : true, changeYear : true});
	$('#waybill').val($(this).data("waybill"));

	$('#sentdate_log').empty();
	getSentDateLog();
	$("#myModal").show();
})

.on("click",".btn-edit-receipttaxinv",function(e){
	e.preventDefault();
	$('#receipt_id').val($(this).data("id"));
	$("#receipt_long_id").text($(this).data("longid"));
	$('#created_at').val($(this).data("createdat"));
	$('#printdate').val($(this).data("printdate"));
	$('#billingdate').val($(this).data("billingdate"));

	$("#myModal").show();
})

.on("submit","#update_tax",function(e){
	e.preventDefault();
	$.ajax({
		url: $(this).attr('action'),
		method: "POST",
		dataType: "json",
		data: $(this).serialize(),
		success:function(data){
			showMessageBox(data.message, 5000);
			console.log(data);
			location.reload();
		},error:function(err) {
			// showMessageBox(data.message,5000);
		}
	})
})

.on("submit","#update_receipttaxinv",function(e){
	e.preventDefault();
	$.ajax({
		url: $(this).attr('action'),
		method: "POST",
		dataType: "json",
		data: $(this).serialize(),
		success:function(data){
			showMessageBox(data.message, 5000);
			console.log(data);
			location.reload();
		},error:function(err) {
			// showMessageBox(data.message,5000);
		}
	})
})

.on("submit",".form_ajax",function(e) {
	resource_name = $(this).data("resource");
	e.preventDefault();
	$.ajax({
		headers: {
			'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
		},
		url: $(this).attr('action'),
		method: 'post',
		contentType: false,
		processData: false,
		data: new FormData(this),
		beforeSend:function() {
			$(".error-message").remove();
			$(".form-control").removeClass("is-invalid");
		},
		success: function(data) {
			if (data.status == 200) {
				location.href = data.url;
			}
		},
		error: function(err) {
			// ;
			err = JSON.parse(err.responseText);
			console.log(err.errors);
			$.each(err.errors,function(column, message) {
				input = $("#"+resource_name+"_"+column+"");
				$(input).addClass("is-invalid");
				parent = $(input).parent();
				
				content = '<span class="error-message" style="color: red; margin-left: 115px; margin-top: 5px; display: block;">'+message[0].message+'</span>';
				$(parent).append(content);
			});
		}
	});
})
.on("submit", "#form-createreceipttaxitem", function(e) {
	e.preventDefault();
	$.ajax({
		url: $(this).attr('action'),
		method: "POST",
		dataType: "json",
		data: $(this).serialize(),
		success:function(data){
			$(".checkbox_receipt:checked").remove();
			showMessageBox(data.message, 5000);
		},error:function(err) {
			showMessageBox("Terjadi kesalahan di sistem", 5000);
		}
	})
})
;

// Get the modal
var modal = document.getElementById("myModal");

// // Get the button that opens the modal
// var btn = document.getElementById("myBtn");

// // Get the <span> element that closes the modal
var span = document.getElementsByClassName("close")[0];

// // When the user clicks the button, open the modal 
// btn.onclick = function() {
//   modal.style.display = "block";
// }

// // When the user clicks on <span> (x), close the modal
span.onclick = function() {
  modal.style.display = "none";
}

// When the user clicks anywhere outside of the modal, close it
window.onclick = function(event) {
  if (event.target == modal) {
    modal.style.display = "none";
  }
}