
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

# recoreder actions

exports.internalCommit = ->
  recorder.dispatch "actions-recorder/commit"

exports.internalReset = ->
  recorder.dispatch "actions-recorder/reset"

exports.internalPeek = (position) ->
  recorder.dispatch "actions-recorder/peek", position

exports.internalRun = ->
  recorder.dispatch "actions-recorder/run"

exports.internalMergeBefore = ->
  recorder.dispatch "actions-recorder/merge-before"

exports.internalClearAfter = ->
  recorder.dispatch "actions-recorder/clear-after"
