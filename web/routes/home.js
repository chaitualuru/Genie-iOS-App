module.exports = function(app) {

	var Firebase = require('firebase');
	var appRef = new Firebase("https://getgenie.firebaseio.com/");

	app.post('/saveUser', function (req, res) {
		console.log(req.body);
		res.cookie('uid', req.body.uid);
		res.cookie('token', req.body.token);
		res.cookie('email', req.body.password.email);
		res.render('home.html');
	});
}