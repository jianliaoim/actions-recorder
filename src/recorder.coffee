
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
        if core.pointer is 0
          {}
        else
          initial: core.records.slice(0, (core.pointer - 1)).reduce updater, core.initial
          records: core.records.slice(core.pointer - 1)
          pointer: 1
      when "clear-after"
        records: core.records.slice(0, core.pointer)
      when 'step'
        backward = actionData
        if backward
          if core.pointer > 0
            nextPointer = core.pointer - 1
          else
            nextPointer = core.pointer
        else
          if core.pointer < core.records.size
            nextPointer = core.pointer + 1
          else
            nextPointer = core.pointer
        pointer: nextPointer
      else
        console.warn "Unknown actions-recorder action: " + actionType
        {}
  else
    records: core.records.push(Immutable.List([actionType, actionData]))

getNewStore = ->
  updater = (acc, action) ->
    core.updater acc, action.get(0), action.get(1)
  if core.isTravelling and core.pointer >= 0
    core.records.slice(0, core.pointer).reduce updater, core.initial
  else
    core.records.reduce updater, core.initial

exports.setup = (options) ->
  assign core, options
  core.cachedStore = core.initial

  if core.inProduction
    setInterval ->
      if core.records.size > 400 and (not core.isTravelling)
        exports.dispatch 'actions-recorder/commit'
    , (10 * 60 * 1000)

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
  assign core, callUpdater(actionType, actionData)
  core.cachedStore = getNewStore()
  recorderEmit core.cachedStore, core
