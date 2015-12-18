var url = window.location.pathname.split('/');
var user_id = url[2];
var user_name = "";
var uploadedFileContents;

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
			timestamp: Date.now()
		}; 
	} else {
		message = {
			sent_by_user: false, 
			deleted_by_user: false, 
			is_media_message: false, 
			text: $("#message_input").val(), 
			timestamp: Date.now()
		};
	}
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
	$.ajax({url: "/get/messages/" + user_id, success: function (messages) {
		if (messages) {
			var len = messages.length
			$.each(messages, function (idx, message) {
				if (message.timestamp) {
					var date = new Date(message.timestamp);
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
			    $("#message-box").animate({ scrollTop: $('#message-box').prop("scrollHeight")}, 00);
			});
		}
	}});
}
getUserProfile();
setInterval(getNewMessages, 2000, true);
document.getElementById('uploadFile').addEventListener('change', readSingleFile, false);
$("#sendMessage").click(sendMessage);
