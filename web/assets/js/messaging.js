var url = window.location.pathname.split('/');
var user_id = url[2];
var user_name = "";
var uploadedFileContents;
var playsound = false;
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
		console.log(response);
		if (response.code == 200) {
			console.log("Yes");
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
					alert(response);
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

function setName () {
	$('.modal-user-name').modal('show');
	$("#user_name_modal").val($("#user-name").text());
}

function setAddress () {
	$('.modal-user-address').modal('show');
	$("#user_address_modal").val($("#user-address").text());
}

function sendName () {
	$.ajax({
		type: "POST",
		url: "/setUserName/" + user_id,
		data: {full_name: $("#user_name_modal").val()},
		success: function (response){
			if (response.code == 200) {
				$('.modal-user-name').modal('toggle');
				getUserProfile(false);
			} else {
				alert(response.message);
			}
		}
	});
}

function sendAddress () {
	$.ajax({
		type: "POST",
		url: "/setUserAddress/" + user_id,
		data: {address: $("#user_address_modal").val()},
		success: function (response){
			if (response.code == 200) {
				$('.modal-user-address').modal('toggle');
				getUserProfile(false);
			} else {
				alert(response.message);
			}
		}
	});	
}

function getUserProfile(loadMessages) {
	$.ajax({url: "/users/" + user_id, success: function (user){
		$('#user-name').text(user.first_name + " " + user.last_name);
		$('#user-email').text(user.email_address);
		$('#user-mobile').text(user.mobile_number);
		$('#user-address').text(user.address);
		user_name = user.first_name;
		if (loadMessages) {
			getNewMessages(false);
		}
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
				var date = String(new Date(message.timestamp * 1000));
				date = date.split(' ');
				date = date[1] + " " + date[2] + ", " + date[4];
				if (message.sent_by_user == true) {
					if (message.is_media_message) {
			        	$("#message-box").append(
			        		"<div class='row msg-box-user' id='" + message.timestamp + "'><div class='col-md-9'><span style='color: red;'>" + user_name + ": </span><img onclick='largerView(this.src)' height='150px' width='300px' src='data:img/png;base64," + message.media + "' /></div><div class='col-md-3'><center>" + date + "</center></div></div>");
			        } else {
			        	$("#message-box").append(
			        		"<div class='row msg-box-user' id='" + message.timestamp + "'><div class='col-md-9'><span style='color: red;'>" + user_name + ": </span>" + message.text + "</div><div class='col-md-3'><center>" + date + "</center></div></div>");
			        }
		        	if (playsound) {
			        	var audio = new Audio('/sounds/new_message.mp3');
						audio.play();
					}
		        } else {
		        	if (message.is_media_message) {
		        		$("#message-box").append(
			        		"<div class='row msg-box-employee' id='" + message.timestamp + "'><div class='col-md-9'>You: <img onclick='largerView(this.src)' height='150px' width='300px' src='data:img/png;base64," + message.media + "' /></div><div class='col-md-3'><center>" + date + "</center></div></div>");
		        	} else {
			        	$("#message-box").append(
			        		"<div class='row msg-box-employee' id='" + message.timestamp + "'><div class='col-md-9'>You: " + message.text + 
			        		"</div><div class='col-md-3'><center>" + date + "</center></div></div>");
			        }
		        }
		    }
		    $('#message-box').scrollTop($('#message-box')[0].scrollHeight);
		});
	});
    playsound = true
}

$('#message-box').scroll(function(){
    if ($('#message-box').scrollTop() == 0){

        // Do Ajax call to get more messages and prepend them
        // To the inner div
        // How you paginate them will be the tricky part though
        // You'll likely have to send the ID of the last message, to retrieve 5-10 'before' that 
        var timestamp = $("#message-box > div")[0].id;

        $.ajax({url: "/moreMessages/" + user_id + "/" + timestamp, success: function (messages){
        	messages.reverse();
        	console.log(messages.length);
        	if (messages.length == 0) {
        		alert('No more messages');
        	}
        	for (idx in messages) {
	        	var message = messages[idx];
	        	if (message.timestamp) {
					var date = String(new Date(message.timestamp * 1000));
					date = date.split(' ');
					date = date[1] + " " + date[2] + ", " + date[4];
					if (message.sent_by_user == true) {
						if (message.is_media_message) {
				        	$("#message-box").prepend(
				        		"<div class='row msg-box-user' id='" + message.timestamp + "'><div class='col-md-9'><span style='color: red;'>" + user_name + ": </span><img onclick='largerView(this.src)' height='150px' width='300px' src='data:img/png;base64," + message.media + "' /></div><div class='col-md-3'><center>" + date + "</center></div></div>");
				        } else {
				        	$("#message-box").prepend(
				        		"<div class='row msg-box-user' id='" + message.timestamp + "'><div class='col-md-9'><span style='color: red;'>" + user_name + ": </span>" + message.text + "</div><div class='col-md-3'><center>" + date + "</center></div></div>");
				        }
			        } else {
			        	if (message.is_media_message) {
			        		$("#message-box").prepend(
				        		"<div class='row msg-box-employee' id='" + message.timestamp + "'><div class='col-md-9'>You: <img onclick='largerView(this.src)' height='150px' width='300px' src='data:img/png;base64," + message.media + "' /></div><div class='col-md-3'><center>" + date + "</center></div></div>");
			        	} else {
				        	$("#message-box").prepend(
				        		"<div class='row msg-box-employee' id='" + message.timestamp + "'><div class='col-md-9'>You: " + message.text + 
				        		"</div><div class='col-md-3'><center>" + date + "</center></div></div>");
				        }
			        }
			    }
			}
			if (messages.length != 0) {
	    		$('#message-box').scrollTop(20);
        	}
		}});
    }
});

getUserProfile(true);
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