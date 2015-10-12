
assign = require("object-assign")
Immutable = require("immutable")

core =
  records: Immutable.List()
  pointer: 0
  isTravelling: false
  initial: Immutable.Map()
  cachedStore: Immutable.Map()
  updater: (state) -> state
  inProduction: false

recorderListeners = Immutable.List()
recorderEmit = (store, core) ->
  recorderListeners.forEach (fn) ->
    fn store, core

callUpdater = (actionType, actionData) ->
  chunks = actionType.split("/")
  groupName = chunks[0]
  updater = (acc, action) ->
    core.updater acc, action.get(0), action.get(1)
  if groupName is "actions-recorder"
    switch chunks[1]
      when "commit"
        initial: core.records.reduce updater, core.initial
        records: Immutable.List()
        pointer: 0
        isTravelling: false
      when "reset"
        records: Immutable.List()
        pointer: 0
        isTravelling: false
      when "peek"
        pointer: actionData
        isTravelling: true
      when "run"
        isTravelling: not core.isTravelling
        pointer: 0
      when "merge-before"
        initial: core.records.slice(0, core.pointer).reduce updater, core.initial
        records: core.records.slice(core.pointer)
        pointer: 0
      when "clear-after"
        records: core.records.slice(0, core.pointer + 1)
        pointer: 0
      else
        console.warn "Unknown actions-recorder action: " + actionType
        {}
  else
    records: core.records.push(Immutable.List([actionType, actionData]))

getNewStore = ->
  updater = (acc, action) ->
    core.updater acc, action.get(0), action.get(1)
  if core.isTravelling and core.pointer >= 0
    core.records.slice(0, core.pointer + 1).reduce updater, core.initial
  else
    core.records.reduce updater, core.initial

exports.setup = (options) ->
  assign core, options
  core.cachedStore = core.initial

exports.request = (fn) ->
  fn core.cachedStore, core

exports.getState = ->
  core.cachedStore

exports.getCore = ->
  core

exports.subscribe = (fn) ->
  # bypass warning of "setState on unmounted component" with unshift
  recorderListeners = recorderListeners.unshift fn

exports.unsubscribe = (fn) ->
  recorderListeners = recorderListeners.filterNot (listener) ->
    listener is fn

exports.dispatch = (actionType, actionData) ->
  actionData = Immutable.fromJS(actionData)
  if core.inProduction
    core.initial = core.updater(core.initial, actionType, actionData)
    core.cachedStore = core.initial
    recorderEmit core.initial, core
  else
    assign core, callUpdater(actionType, actionData)
    core.cachedStore = getNewStore()
    recorderEmit core.cachedStore, core
  return
