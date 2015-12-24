module.exports = function (app, ref, server) {
	var baseURL = "https://getgenie.firebaseio.com"
	var Firebase = require('firebase');
	var Handlebars = require('handlebars');
	var bcrypt = require('bcrypt'), SALT_WORK_FACTOR = 10;
	var mRef = new Firebase(baseURL + "/messages");
	var msgRef = {};
	var userRef = {};
	var activeRequests = {};
	var io = require('socket.io')(server);
	//------------------------------------------- LANDING -------------------------------------------------------

	//------------------------------------------- LANDING PAGE --------------------------------------------------


	//------------------------------------------- REGISTER --------------------------------------------------
	app.get('/register', function (req, res) {
		res.render('register');
	});

	app.post('/createUser', function (req, res) {
		var employee = new Employees(req.body);
		bcrypt.genSalt(SALT_WORK_FACTOR, function(err, salt) {
	        if (err) {
	        	console.error(err);
	        }
	        else {
		        bcrypt.hash(req.body.password, salt, function(err, hash) {
		            if (err) {
						console.error(err);
		            }
		            else {
			            employee.password = hash;
			            employee.save(function (err, result) {
							if (err){
								console.error(err);
							} else {
								console.log("Employee Created.");
				    			res.redirect('/');
							}
						});
			        }
		        });
		    }
	    });
	});
	//------------------------------------------- REGISTER END ----------------------------------------------



	//------------------------------------------- LOGIN -----------------------------------------------------
	app.get('/', function (req, res) {
		if (req.session.uid)
			res.redirect('home');
		else 
			res.render('index');
	});

	app.post('/login', function (req, res) {
		Employees.findOne({'email': req.body.email }).exec(function (err, employee){
			if (err) {
				console.error(err);
			}
			else {
				if (employee) {
					bcrypt.compare(req.body.password, employee.password, function(err, isMatch) {
			            if (err) {
							console.error(err);
			            }
			            else {
			            	if (isMatch) {
			            		if (employee.approved == false) {
				            		console.log("Authenticated successfully.");
					    			req.session['uid'] = employee.id;
					    			res.redirect('home');
					    		} else {
					    			res.set('Content-Type', 'application/json');
									res.send(JSON.stringify({
										code: 403,
										message: "Approval Pending"
									}));
					    		}
			            	}
			            	else {
			            		res.set('Content-Type', 'application/json');
								res.send(JSON.stringify({
									code: 401,
									message: "Invalid Credentials"
								}));
			            	}
			            }
		           });
		        }
	            else {
	            	res.set('Content-Type', 'application/json');
					res.send(JSON.stringify({
						code: 404,
						message: "User not found"
					}));
	            }
			}
		});
	});
	//----------------------------------------- LOGIN END ---------------------------------------------------



	//-------------------------------------- ACTIVE REQUESTS ------------------------------------------------
	app.get('/home', function (req, res) {
		if (!req.session.uid) {
			res.redirect('/');
		}
		else {
			activeRequests = {};
			var usersRef = new Firebase(baseURL + "/users/");

			usersRef.on("value", function (snapshot) {
				var users = snapshot.val();
				for (uid in users) {
					var mRef = new Firebase(baseURL + "/messages/" + uid);
		  			mRef.limitToLast(1).on("value", function (snapshot) {
		  				var message = snapshot.val();
		  				if (snapshot.val() != null) {
		  					var user_id = snapshot.ref().toString();
		  					user_id = user_id.split("/");
		  					user_id = user_id[user_id.length - 1];
		  					var userRef = new Firebase(baseURL + "/users/" + user_id);
		  					for (mid in message) {
			  					userRef.once("value", function (snapshot) {
			  						var user = snapshot.val();
			  						if (user.serviced == 0) {
							  			var active = {
							  				message: message[mid].text, 
							  				id: user_id, 
							  				timestamp: message[mid].timestamp
							  			}
							  			if (active.message == "") {
							  				active.message = "Image."
							  			}
							  			activeRequests[user_id] = active;
							  		} else {
							  			delete activeRequests[user_id];
							  		}
		  						});
			  				}
						}
					}, function(error) {
						console.log(error);
					});
		  		}
	  		});
			res.render('home');
		}
	});

	app.get('/activeRequests', function (req, res) {
		var requests = [];
		for (item in activeRequests) {
			requests.push(activeRequests[item]);
		}
		res.send(requests);
	});
	//-------------------------------------- ACTIVE REQUESTS END --------------------------------------------



	//-------------------------------------- MESSAGING ------------------------------------------------------
	io.on('connection', function(socket) {
		socket.on("id", function (msg_id) {
			userRef[msg_id] = new Firebase(baseURL + "/users/" + msg_id);
			userRef[msg_id].update({serviced: -1});
			console.log("User Id: " + msg_id);
			msgRef[msg_id] = new Firebase(baseURL + "/messages/" + msg_id);
			msgRef[msg_id].on("child_added", function (snapshot) {
				var msg = snapshot.val();
				socket.emit(msg_id, msg);
			}, function(error) {
				console.log(error);
			});
		});
	});

	app.get('/messages/:msg_id', function (req, res) {
		if (!req.session.uid) {
			res.redirect('/');
		} else {
			res.render('messaging');
		}
	});

	app.post('/send/messages/:msg_id', function (req, res) {
		if (!req.session.uid) {
			res.redirect('/'); 
		} else {
			var msgRef = new Firebase(baseURL + "/messages/" + req.params.msg_id);
			var response, userFlag, newMessage;
			if (req.body.sent_by_user == "false")
				userFlag = false;
			else
				userFlag = true;
			if (req.body.is_media_message == "false") {
				newMessage = {
					'sent_by_user': userFlag,
					'text': req.body.text,
					'deleted_by_user': false,
					'is_media_message': false,
					'timestamp': parseInt(req.body.timestamp)
				}
			}
			else {
				newMessage = {
					'sent_by_user': userFlag,
					'text': req.body.text,
					'deleted_by_user': false,
					'is_media_message': true,
					'media': req.body.media,
					'timestamp': parseInt(req.body.timestamp)
				}
			}
			msgRef.push(newMessage, function (error) {
				if (error) {
					res.send({code: 400, message: error});
				} else {
					res.send({code: 200, message: "OK"});
				}
			});
		}	
	});

	app.get('/users/:user_id', function (req, res) {
		if (!req.session.uid) {
			res.redirect('/'); 
		} else {
			var userRef = new Firebase(baseURL + "/users/" + req.params.user_id);
			userRef.once("value", function (user) {
				res.send(user.val());
			});
		}
	});

	app.get('/denyRequest/:user_id', function (req, res) {
		if (!req.session.uid) {
			res.redirect('/'); 
		} else {
			var usersRef = new Firebase(baseURL + "/users/" + req.params.user_id);
			usersRef.update({serviced: 1});
			res.send({code: 200, message: "OK"});
		}
	});

	app.get('/completeRequest/:user_id', function (req, res) {
		if (!req.session.uid) {
			res.redirect('/');
		} else {
			var usersRef = new Firebase(baseURL + "/users/" + req.params.user_id);
			usersRef.update({serviced: 1});
			res.send({code: 200, message: "OK"});
		}
	});
	//-------------------------------------- MESSAGING END --------------------------------------------------



	//--------------------------------------------- ORDERS --------------------------------------------------
	app.post('/send/orders/:user_id', function (req, res) {
		if (!req.session.uid) {
			res.redirect('/'); 
		} else {
			var orderRef = new Firebase(baseURL + "/orders/" + req.params.user_id);
			var order = req.body;
			order.associated_employee_id = req.session.uid;
			order.timestamp = parseInt(order.timestamp);
			orderRef.push(order, function (error) {
				if (error) {
					res.send({code: 400, message: error});
				} else {
					res.send({code: 200, message: "OK"});
				}
			});
		}	
	});

	app.post('/update/order/:user_id/:order_id', function (req, res) {
		if (!req.session.uid) {
			res.redirect('/'); 
		} else {
			var orderRef = new Firebase(baseURL + "/orders/" + req.params.user_id + "/" + req.params.order_id);
			var order = req.body;
			order.associated_employee_id = req.session.uid;
			order.timestamp = parseInt(order.timestamp);
			orderRef.update(order);
			res.send({code: 200, message: "OK"});
		}	
	});

	app.get('/orders/:user_id', function (req, res) {
		if (!req.session.uid) {
			res.redirect('/'); 
		} else {
			var orderRef = new Firebase(baseURL + "/orders/" + req.params.user_id);
			orderRef.once("value", function (data){
				var allOrders = [];
				var orders = data.val();
				for (item in orders) {
					var order = {
						order_id: item,
						category: orders[item].category,
						status: orders[item].status,
						description: orders[item].description,
						timestamp: orders[item].timestamp,
						company: orders[item].company
					}
					allOrders.push(order);
				}
				allOrders.reverse();
				res.send(allOrders);
			});
		}
	});

	//--------------------------------------------- ORDERS END ----------------------------------------------
}