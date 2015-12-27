var url = window.location.pathname.split('/');
var user_id = url[2];
var user_name = "";
var uploadedFileContents;
var playsound = true;
var toUpdateOrder;

$("#denyRequest").click(function () {
	$.ajax({url: "/denyRequest/" + user_id, success: function(response) {
		if (response.code == 200) {
			window.close();
		}
	}});
});

$("#completeRequest").click(function () {
	$.ajax({url: "/completeRequest/" + user_id, success: function(response) {
		if (response.code == 200) {
			window.close();
		}
	}});
});

function readSingleFile(e) {
	var file = e.target.files[0];
  	if (!file) {
    	return;
  	}
  	var reader = new FileReader();
  	reader.onload = function(e) {
    	uploadedFileContents = e.target.result;
    	console.log("File Read");
  	};
  	reader.readAsDataURL(file);
}

function sendMessage () {
	var message;
	if ($('#uploadFile').val()) {
		message = {
			sent_by_user: false, 
			deleted_by_user: false, 
			is_media_message: true, 
			media: uploadedFileContents.split(",")[1],
			text: "", 
			timestamp: parseInt(Date.now() / 1000)
		}; 
	} else {
		message = {
			sent_by_user: false, 
			deleted_by_user: false, 
			is_media_message: false, 
			text: $("#message_input").val(), 
			timestamp: parseInt(Date.now() / 1000)
		};
	}
	if ((message.text != "" && !message.is_media_message) || (message.is_media_message)) {
		$.ajax({
			type: "POST",
			url: "/send/messages/" + user_id,
			data: message,
			success: function (response){
				if (response.code == 200) {
					$("#message_input").val("");
					$('#uploadFile').val("");
					console.log("Uploaded");
				} else {
					alert(response.message);
				}
			}
		});
	}
}

function showOrderModal () {
	$('#modal-order').modal('show');
}

function getOrders () {
	$('#orders').empty();
	$.ajax({url: "/orders/" + user_id, success: function (orders){
		for (idx in orders) {
			var order = orders[idx];
			var date = new Date(order.timestamp * 1000);
			date = String(date);
			date = date.split(" ");
			date = date[1] + " " + date[2] + ", " + date[3] + " | " + date[4];
			$("#orders").append("<div class='order-item'>" + order.description + " | " + order.company + " | " + order.category + "<br>" + date  + "  <strong>" + order.status + "</strong> <button type='button' class='btn btn-xs btn-primary' onclick='updateOrderModal({order_id: \"" + order.order_id + "\", status: \"" + order.status + "\", category: \"" + order.category +"\", description: \"" + order.description + "\", company: \"" + order.company + "\"})'>Edit</button><div><hr>");
		}
	}});
}

function placeOrder () {
	var order = {
		company: $("#company").val(),
		description: $("#description").val(),
		timestamp: parseInt(Date.now() / 1000),
		associated_employee_id: "",
		status: $("#status").val(),
		category: $("#category").val()
	}
	if (order.company && order.description && order.category && order.status) {
		$.ajax({
			type: "POST",
			url: "/send/orders/" + user_id,
			data: order,
			success: function (response){
				if (response.code == 200) {
					$('#modal-order').modal('toggle');
					getOrders();
				} else {
					alert(response.message);
				}
			}
		});
	} else {
		alert("Please fill all fields!");
	}
}

function updateOrderModal (order) {
	$('#modal-order-update').modal('show');
	$("#company-update").val(order.company);
	$("#description-update").val(order.description);
	$("#status-update").val(order.status);
	$("#category-update").val(order.category)

	toUpdateOrder = order.order_id;
}

function updateOrder () {
	var order = {
		company: $("#company-update").val(),
		description: $("#description-update").val(),
		timestamp: parseInt(Date.now() / 1000),
		associated_employee_id: "",
		status: $("#status-update").val(),
		category: $("#category-update").val()
	}

	if (order.company && order.description && order.category && order.status) {
		$.ajax({
			type: "POST",
			url: "/update/order/" + user_id + "/" + toUpdateOrder,
			data: order,
			success: function (response){
				if (response.code == 200) {
					$('#modal-order-update').modal('toggle');
					getOrders();
				} else {
					alert(response.message);
				}
			}
		});
	} else {
		alert("Please fill all fields!");
	}
}

function getUserProfile() {
	$.ajax({url: "/users/" + user_id, success: function (user){
		$('#user-name').text(user.first_name + " " + user.last_name);
		$('#user-email').text(user.email_address);
		$('#user-mobile').text(user.mobile_number);
		user_name = user.first_name;
		getNewMessages(false);
	}});
}

function largerView (src) {
	$('#image-preview').attr('src', src);
	$('#modal-image').modal('show');
}

function getNewMessages(playsound) {
	var iosocket = io.connect();
	iosocket.on('connect', function () {
		iosocket.emit('id', user_id);
		iosocket.on(user_id, function(message) {
			if (message.timestamp) {
				var date = new Date(message.timestamp * 1000);
				date = date.toGMTString();
				date = date.split(' ');
				date = date[1] + " " + date[2] + ", " + date[4];
				if (message.sent_by_user == true) {
					if (message.is_media_message) {
			        	$("#message-box").append(
			        		"<div class='row msg-box-user'><div class='col-md-9'><span style='color: red;'>" + user_name + ": </span><img onclick='largerView(this.src)' height='150px' width='300px' src='data:img/png;base64," + message.media + "' /></div><div class='col-md-3'><center>" + date + "</center></div></div>");
			        } else {
			        	$("#message-box").append(
			        		"<div class='row msg-box-user'><div class='col-md-9'><span style='color: red;'>" + user_name + ": </span>" + message.text + "</div><div class='col-md-3'><center>" + date + "</center></div></div>");
			        }
		        	if (playsound) {
			        	var audio = new Audio('/sounds/new_message.mp3');
						audio.play();
					}
		        } else {
		        	if (message.is_media_message) {
		        		$("#message-box").append(
			        		"<div class='row msg-box-employee'><div class='col-md-9'>You: <img onclick='largerView(this.src)' height='150px' width='300px' src='data:img/png;base64," + message.media + "' /></div><div class='col-md-3'><center>" + date + "</center></div></div>");
		        	} else {
			        	$("#message-box").append(
			        		"<div class='row msg-box-employee'><div class='col-md-9'>You: " + message.text + 
			        		"</div><div class='col-md-3'><center>" + date + "</center></div></div>");
			        }
		        }
		    }
		    playsound = true
		    $("#message-box").animate({ scrollTop: $('#message-box').prop("scrollHeight")}, 100);
		});
	});
}
getUserProfile();
getOrders();
document.getElementById('uploadFile').addEventListener('change', readSingleFile, false);
$("#message_input").keyup(function(event){
    if(event.keyCode == 13){
        $("#sendMessage").click();
    }
});
$("#sendMessage").click(sendMessage);
$("#placeOrderModal").click(showOrderModal);
$("#placeOrder").click(placeOrder);
$("#updateOrder").click(updateOrder);