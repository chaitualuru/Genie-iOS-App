module.exports = function(app) {
	app.get('/', function (req, res) {
		res.render('index.html');
	});

	app.get('/home', function (req, res) {
		if (res.cookie) {
			console.log("YES");
			res.render('home.html');
		} else {
			res.render('index.html');
		}
	});
}