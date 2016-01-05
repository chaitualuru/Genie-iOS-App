function compare(a, b) {
	if (a.timestamp < b.timstamp)
		return -1;
	if (a.timestamp > b.timestamp)
    	return 1;
  	return 0;
}

function getAgoTime (timediff) {
	timediff = timediff;
	if (timediff > 86400) {
		days = timediff / 86400;
		return parseInt(days) + "days ago";
	} else if (timediff > 3600) {
		hours = timediff / 3600;
		return parseInt(hours) + "hours ago";
	} else if (timediff > 60) {
		minutes = timediff / 60;
		return parseInt(minutes) + "minutes ago";
	} else {
		return parseInt(timediff) + "seconds ago";
	}
}

function update () {
    $.ajax({url: "/activeRequests", success: function(requests){
    	var prevReqs = []
    	$('.activeRequests a').each(function(idx, elem) {
		    var url = $(this).attr('href');
		    prevReqs.push(url.split("/")[2]);
		});
    	$("#requests").empty();
    	requests.sort(compare);
        $.each(requests, function (idx, request) {
        	if (prevReqs.indexOf(request.id) == -1) {
	    		var audio = new Audio('/sounds/new_request.mp3');
				audio.play();
	    	}
        	$("#requests").append(
        		"<div class='row activeRequests'><p class='left'>" + request.message + 
        		"</p><p class='right timestamp'>" + getAgoTime(Date.now()/1000 - request.timestamp) + "</p><br /></br /><a target='_blank' href='/messages/" + request.id + "' class='btn btn-primary'>Serve Request</a></div>");
        });
    }});
}
update();
setInterval(update, 5000);