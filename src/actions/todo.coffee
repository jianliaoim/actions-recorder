
shortid = require 'shortid'
recorder = require '../recorder'
schema = require '../schema'

exports.add = ->
  task = schema.task.set 'id', shortid.generate()
  recorder.dispatch "todo/add", task

exports.update = (id, text) ->
  recorder.dispatch "todo/update",
    id: id
    text: text

exports.toggle = (id) ->
  recorder.dispatch "todo/toggle", id

exports.remove = (id) ->
  recorder.dispatch "todo/remove", id
