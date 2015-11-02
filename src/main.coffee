
React = require("react")
ReactDOM = require 'react-dom'
Immutable = require("immutable")

recorder = require("./recorder")
updater = require("./updater")
schema = require './schema'

require "origami-ui"
require "../style/main.css"

defaultInfo =
  initial: schema.store
  updater: updater
  inProduction: false

rawPersistent = localStorage.getItem("actions-recorder")
if rawPersistent
  try
    jsonPersistent = JSON.parse(rawPersistent)
    defaultInfo.initial = Immutable.fromJS(jsonPersistent.initial)
    defaultInfo.records = Immutable.fromJS(jsonPersistent.records)
    defaultInfo.pointer = jsonPersistent.pointer
    defaultInfo.isTravelling = jsonPersistent.isTravelling

recorder.setup defaultInfo
if module.hot
  module.hot.accept ['./updater', './schema'], ->
    schema = require './schema'
    updater = require './updater'
    recorder.hotSetup
      initial: schema.store
      updater: updater

window.onbeforeunload = ->
  recorder.request (core) ->
    jsonPersistent =
      records: core.get('records').toJS()
      initial: core.get('initial').toJS()
      pointer: core.get('pointer')
      isTravelling: core.get('isTravelling')

    rawPersistent = JSON.stringify(jsonPersistent)
    localStorage.setItem "actions-recorder", rawPersistent


Page = React.createFactory(require("./app/page"))
render = (core) ->
  ReactDOM.render Page({core}), document.querySelector('.app')

recorder.request render
recorder.subscribe render
