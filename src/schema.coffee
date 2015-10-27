
Immutable = require 'immutable'

exports.store = Immutable.fromJS []

exports.task = Immutable.fromJS
  done: false
  text: ''
  id: null
