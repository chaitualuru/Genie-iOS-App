var mongoose = require('mongoose');

var betaUsers = mongoose.Schema({
	email: {
		type: 'String',
		required: true
	}, 
	timestamp: {
		type: 'String',
		required: true
	},
	sent: {
		type: Boolean,
		default: false
	}
});

module.exports = mongoose.model('betaUsers', betaUsers);