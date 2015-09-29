var express = require('express');
var app = express();

var bodyParser = require('body-parser');

app.use(bodyParser.urlencoded({ extended: true }))

app.set('port', (process.env.PORT || 5000));
app.use(express.static('views'));
app.set('views', 'views');
app.engine('html', require('ejs').renderFile);
app.set('view engine', 'html');

var server = app.listen(3000, function () {
  var host = server.address().address;
  var port = server.address().port;

  console.log('app listening......');

});


require('./routes/auth.js')(app);
require('./routes/home.js')(app);