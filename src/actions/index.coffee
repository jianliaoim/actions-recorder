
todo = require './todo'

exports.add = todo.add
exports.update = todo.update
exports.toggle = todo.toggle
exports.remove = todo.remove

if module.hot
  module.hot.accept ['./todo'], ->
    todo = require './todo'

    exports.add = todo.add
    exports.update = todo.update
    exports.toggle = todo.toggle
    exports.remove = todo.remove
