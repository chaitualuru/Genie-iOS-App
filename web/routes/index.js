module.exports = function (app, ref, server) {
	var path = require('path');
	var baseURL = "https://getgenie.firebaseio.com"
	var Firebase = require('firebase');
	var Handlebars = require('handlebars');
	var bcrypt = require('bcrypt'), SALT_WORK_FACTOR = 10;
	var mRef = new Firebase(baseURL + "/messages");
	var msgRef = {};
	var userRef = {};
	var activeRequests = {};
	var apn = require('apn');
	var io = require('socket.io')(server);
	var options = {
    	"cert": path.join(__dirname, "/cert.pem"),
	    "key":  path.join(__dirname, "/key.pem"),
	    "production": true
	}
	var apnConnection = new apn.Connection(options);

	var wit = require('node-wit');
	var fs = require('fs');
	var ACCESS_TOKEN = "LJCHYD3NUSCOBFN44QXDNIV6B5ZCN7DC";

	//------------------------------------------- LANDING -------------------------------------------------------
	app.get('/', function (req, res) {
		res.render('landing', { layout: false })
	});
	//------------------------------------------- LANDING END --------------------------------------------------


	//------------------------------------------- TIMESTAMP -----------------------------------------------------
	app.get('/timestamp', function (req, res) {
		res.send({timestamp: Math.floor(Date.now() / 1000)});
	});
	//------------------------------------------- TIMESTAMP END--------------------------------------------------


	//------------------------------------------- INVITE REGISTRATION -------------------------------------------
	app.post('/registerForInvite', function (req, res) {
		var betaUser = new BetaUsers(req.body);
		betaUser.save(function (err, result) {
			if (err){
				res.send({code: 400, message: err});
			} else {
				console.log("Beta User Registered.");
    			res.send({code: 200, message: "Beta User Registered"});
			}
		});
	});
	//------------------------------------------- NVITE REGISTRATION END ----------------------------------------



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
				    			res.redirect('/auth');
							}
						});
			        }
		        });
		    }
	    });
	});
	//------------------------------------------- REGISTER END ----------------------------------------------



	//------------------------------------------- LOGIN -----------------------------------------------------
	app.get('/auth', function (req, res) {
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
			res.redirect('/auth');
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
			// Add query details to limit the number of messages initially loaded.
			msgRef[msg_id].orderByChild("timestamp").limitToLast(30).on("child_added", function (snapshot) {
				var msg = snapshot.val();

				// console.log("Sending text to Wit.AI");

				wit.captureTextIntent(ACCESS_TOKEN, msg.text, function (err, res) {
				    // console.log("Response from Wit for text input: ");
				    // if (err) console.log("Error: ", err);
				    // console.log(JSON.stringify(res, null, " "));
				});

				socket.emit(msg_id, msg);
			}, function(error) {
				console.log(error);
			});
		});
	});

	app.get('/moreMessages/:user_id/:timestamp', function (req, res) {
		if (!req.session.uid) {
			res.redirect('/auth');
		} else {
			var mRef = new Firebase(baseURL + "/messages/" + req.params.user_id);
			var messages = [];
			mRef.orderByChild("timestamp").endAt(parseInt(req.params.timestamp)).limitToLast(20).once("value", function (snapshot) {
				var msgs = snapshot.val();
				for (item in msgs) {
					var msg = msgs[item];
					messages.push(msg);
				}
				messages.pop();
				res.send(messages);
			});
		}
	});

	app.get('/messages/:msg_id', function (req, res) {
		if (!req.session.uid) {
			res.redirect('/auth');
		} else {
			res.render('messaging');
		}
	});

	app.post('/send/messages/:msg_id', function (req, res) {
		if (!req.session.uid) {
			res.redirect('/auth'); 
		} else {
			var msgRef = new Firebase(baseURL + "/messages/" + req.params.msg_id);
			var userRef = new Firebase(baseURL + "/users/" + req.params.msg_id);
			userRef.once("value", function (snapshot) {
				var user = snapshot.val();
				if (user.application_state != 1) {
					console.log(user.device_token);
					var myDevice = new apn.Device(user.device_token);
					var notification = new apn.Notification();

					notification.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
					notification.sound = "default";
					if (req.body.is_media_message == "true") {
						notification.alert = "You received an image.";
					}
					else {
						notification.alert = req.body.text;
					}
					notification.payload = {'messageFrom': 'Employee'};

					apnConnection.pushNotification(notification, myDevice);
				}
			});
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
					'timestamp': Math.floor(Date.now() / 1000)
				}
			}
			else {
				newMessage = {
					'sent_by_user': userFlag,
					'text': req.body.text,
					'deleted_by_user': false,
					'is_media_message': true,
					'media': req.body.media,
					'timestamp': Math.floor(Date.now() / 1000)
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
			res.redirect('/auth'); 
		} else {
			var userRef = new Firebase(baseURL + "/users/" + req.params.user_id);
			userRef.once("value", function (user) {
				res.send(user.val());
			});
		}
	});

	app.get('/denyRequest/:user_id', function (req, res) {
		if (!req.session.uid) {
			res.redirect('/auth'); 
		} else {
			var usersRef = new Firebase(baseURL + "/users/" + req.params.user_id);
			usersRef.update({serviced: 1});
			res.send({code: 200, message: "OK"});
		}
	});

	app.get('/completeRequest/:user_id', function (req, res) {
		if (!req.session.uid) {
			res.redirect('/auth');
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
			res.redirect('/auth'); 
		} else {
			var orderRef = new Firebase(baseURL + "/orders/" + req.params.user_id);
			var order = req.body;
			order.associated_employee_id = req.session.uid;
			order.timestamp = Math.floor(Date.now() / 1000);
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
			res.redirect('/auth'); 
		} else {
			var orderRef = new Firebase(baseURL + "/orders/" + req.params.user_id + "/" + req.params.order_id);
			var order = req.body;
			order.associated_employee_id = req.session.uid;
			order.timestamp = Math.floor(Date.now() / 1000);
			orderRef.update(order);
			res.send({code: 200, message: "OK"});
		}	
	});

	app.get('/orders/:user_id', function (req, res) {
		if (!req.session.uid) {
			res.redirect('/auth'); 
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



	//--------------------------------------------- USER ENTITIES -------------------------------------------

	app.post('/setUserName/:user_id', function (req, res) {
		if (!req.session.uid) {
			res.redirect('/auth'); 
		} else {
			var userRef = new Firebase(baseURL + "/users/" + req.params.user_id);
			var name = req.body.full_name;
			name = name.split(" ");
			if (name.length < 2) { 
				userRef.update({first_name: name[0], last_name: ""});
			} else if (name.length >= 2) {
				var firstName = name.splice(0, 1);
				userRef.update({first_name: firstName[0], last_name: name.join(" ")});
			}
			res.send({code: 200, message: "OK"});
		}	
	});


	app.post('/setUserAddress/:user_id', function (req, res) {
		if (!req.session.uid) {
			res.redirect('/auth'); 
		} else {
			var userRef = new Firebase(baseURL + "/users/" + req.params.user_id);
			var address = req.body.address;
			userRef.update({address: address});
			res.send({code: 200, message: "OK"});
		}
	});

	//--------------------------------------------- USER ENTITIES END ---------------------------------------
}