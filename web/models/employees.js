var mongoose = require('mongoose');

var employeesSchema = mongoose.Schema({
	name: {
		type: 'String',
		required: false
	},
	email: {
		type: 'String',
		required: true
	},
	password: {
		type: 'String',
		required: true
	},
	timestamp: {
		type: 'String',
		required: true
	},
	approved: {
		type: Boolean,
		default: false
	}
});

module.exports = mongoose.model('employees', employeesSchema);