
shortid = require("shortid")
recorder = require("./core/recorder")

exports.add = ->
  recorder.dispatch "todo/add",
    id: shortid.generate()
    done: false
    text: ""

exports.update = (id, text) ->
  recorder.dispatch "todo/update",
    id: id
    text: text

exports.toggle = (id) ->
  recorder.dispatch "todo/toggle", id

exports.remove = (id) ->
  recorder.dispatch "todo/remove", id
