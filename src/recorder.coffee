
Immutable = require("immutable")

core = Immutable.Map
  records: Immutable.List()
  pointer: 0
  isTravelling: false
  initial: Immutable.Map()
  cachedStore: Immutable.Map()
  updater: (state) -> state
  inProduction: false

recorderListeners = Immutable.List()
recorderEmit = ->
  recorderListeners.forEach (fn) ->
    fn core

callUpdater = (actionType, actionData) ->
  chunks = actionType.split("/")
  groupName = chunks[0]
  updater = (acc, action) ->
    core.get('updater') acc, action.get(0), action.get(1)
  if groupName is "actions-recorder"
    switch chunks[1]
      when "commit"
        initial: core.get('records').reduce updater, core.get('initial')
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
        isTravelling: not core.get('isTravelling')
        pointer: 0
      when "merge-before"
        if core.get('pointer') is 0
          {}
        else
          initial: core.get('records').slice(0, (core.get('pointer') - 1)).reduce updater, core.get('initial')
          records: core.get('records').slice(core.get('pointer') - 1)
          pointer: 1
      when "clear-after"
        records: core.get('records').slice(0, core.get('pointer'))
      when 'step'
        backward = actionData
        if backward
          if core.get('pointer') > 0
            nextPointer = core.get('pointer') - 1
          else
            nextPointer = core.get('pointer')
        else
          if core.get('pointer') < core.get('records').size
            nextPointer = core.get('pointer') + 1
          else
            nextPointer = core.get('pointer')
        pointer: nextPointer
      else
        console.warn "Unknown actions-recorder action: " + actionType
        {}
  else
    records: core.get('records').push(Immutable.List([actionType, actionData]))

getStore = ->
  updater = (acc, action) ->
    core.get('updater') acc, action.get(0), action.get(1)
  if core.get('isTravelling') and core.get('pointer') >= 0
    core.get('records').slice(0, core.get('pointer')).reduce updater, core.get('initial')
  else
    core.get('records').reduce updater, core.get('initial')

exports.setup = (options) ->
  core = core.merge Immutable.fromJS(options)
  core = core.set 'cachedStore', core.get('initial')

  if core.get('inProduction')
    setInterval ->
      if core.get('records').size > 400 and (not core.get('isTravelling'))
        exports.dispatch 'actions-recorder/commit'
    , (10 * 60 * 1000)

exports.hotSetup = (options) ->
  core = core.merge Immutable.fromJS(options)
  code = core.set 'cachedStore', getStore()
  recorderEmit()

exports.request = (fn) ->
  fn core

exports.getState = ->
  core.get('cachedStore')

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
  core = core.merge callUpdater(actionType, actionData)
  core = core.set 'cachedStore', getStore()
  recorderEmit()
