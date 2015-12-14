var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var exphbs  = require('express-handlebars');
var session = require('express-session');
var cookieParser = require('cookie-parser');
var mongoose = require('mongoose');


app.use(cookieParser());
app.use(session({secret: 'vQZ4mv5d2NNCSwmDrWPB2ork5NfAYtke3Qx2iBHW'}));

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.engine('handlebars', exphbs({defaultLayout: 'main'}));
app.set('view engine', 'handlebars');
app.use(express.static('assets'));

var Firebase = require('firebase');
var ref = new Firebase("https://getgenie.firebaseio.com");

var server = app.listen(3000, function () {
  	var host = server.address().address;
  	var port = server.address().port;

  	console.log('app listening......');
});


require('./config/credentials.js')(app, mongoose);
require('./routes/index.js')(app, ref);

Employees = require('./models/employees.js');

// --------------------------------- Authenticate the server to Firebase ------------------------------------
function authenticate () {
	ref.authWithPassword({
		"email": "employee@genie.com",
	  	"password": "Genie123"
	}, function(error, authData) {
	  	if (error) {
			console.log("Server Authentication Failed!", error);
			res.end("Not OK");
		} else {
			console.log("Server Authenticated Successfully.");
			console.log(authData);
		}
	});
}
authenticate();
setInterval(authenticate, 23*60*60*1000);
//------------------------------------- Authentication END --------------------------------------------------
