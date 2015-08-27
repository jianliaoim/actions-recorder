
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

exports.internalCommit = ->
  recorder.dispatch "actions-recorder/commit"

exports.internalSwitch = ->
  recorder.dispatch "actions-recorder/switch"

exports.internalReset = ->
  recorder.dispatch "actions-recorder/reset"

exports.internalPeek = (position) ->
  recorder.dispatch "actions-recorder/peek", position

exports.internalDiscard = ->
  recorder.dispatch "actions-recorder/discard"
