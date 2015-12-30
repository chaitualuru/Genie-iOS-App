function validateEmail (email) {
	var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
  	return regex.test(email);
}
function registerForInvite () {
	var email = $("#email").val();
	if (validateEmail(email)) {
		$("#email").css("border-color", "#00ff00");
		$.ajax({
			type: "POST",
			url: "/registerForInvite/",
			data: {
				email: email,
				timestamp: Date.now()
			},
			success: function (response){
				if (response.code == 200) {
					$('#modal-betaRegister').click();
					$("#email").val('');
				} else {
					$('#emailRequestMessage').text("Sorry we are not taking any more invites presently. Come back again.");
					$('#modal-betaRegister').click();
					$("#email").val('');
				}
			}
		});
	} else {
		$("#email").css("border-color", "red");
		$("#email").css("border-width", "2px");
	}
}

$("#email").keyup(function(event){
    if(event.keyCode == 13){
        $("#sendEmail").click();
    }
});