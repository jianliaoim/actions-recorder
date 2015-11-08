
diff = require 'immutablediff'
Immutable = require("immutable")

core = Immutable.Map
  records: Immutable.List()
  pointer: 0
  isTravelling: false
  initial: Immutable.Map()
  store: Immutable.Map()
  diff: null
  updater: (state) -> state
  inProduction: false

recorderListeners = Immutable.List()
recorderEmit = ->
  recorderListeners.forEach (fn) ->
    fn exports.getCore()

getStoreFrom = (records) ->
  updateHandler = core.get 'updater'
  updater = (acc, action) ->
    updateHandler acc, action.get(0), action.get(1), action.get(2)
  records.reduce updater, core.get('initial')

# main updater

callUpdater = (actionType, actionData, actionMeta) ->
  pointer = core.get('pointer')
  records = core.get('records')

  [groupName, actionName] = actionType.split("/")
  if groupName is "actions-recorder"
    switch actionName
      when "commit"
        newStore = getStoreFrom records
        initial: newStore
        store: newStore
        records: Immutable.List()
        pointer: 0
        isTravelling: false
        diff: null
      when "reset"
        records: Immutable.List()
        pointer: 0
        isTravelling: false
        store: core.get('initial')
        diff: null
      when "peek"
        nextPointer = actionData
        if nextPointer is 0
          pointer: 0
          isTravelling: true
          store: core.get('initial')
          diff: null
        else
          newStore = getStoreFrom(records.slice(0, nextPointer))
          prevStore = getStoreFrom(records.slice(0, nextPointer - 1))
          pointer: nextPointer # pointer in integer
          isTravelling: true
          store: newStore
          diff: diff prevStore, newStore
      when "run"
        isTravelling: false
        pointer: 0
        store: getStoreFrom(records)
        diff: null
      when "merge-before"
        if pointer <= 1
          {}
        else
          newStore = getStoreFrom records.slice(0, pointer)
          initial: newStore
          records: records.slice(pointer - 1)
          pointer: 1
          store: newStore
      when "clear-after"
        if pointer is records.size
          {}
        else
          newRecords = records.slice(0, pointer)
          records: newRecords
          store: getStoreFrom(newRecords)
      when 'step'
        if actionData # going backward?
          if pointer > 0
            nextPointer = pointer - 1
            newStore = getStoreFrom(records.slice(0, nextPointer))
            prevStore = getStoreFrom(records.slice(0, nextPointer - 1))
            pointer: nextPointer
            store: newStore
            diff: diff prevStore, newStore
          else
            {}
        else
          if pointer < records.size
            nextPointer = pointer + 1
            newStore = getStoreFrom(records.slice(0, nextPointer))
            prevStore = getStoreFrom(records.slice(0, nextPointer - 1))
            pointer: nextPointer
            store: newStore
            diff: diff prevStore, newStore
          else
            {}
      else
        console.warn "Unknown actions-recorder action: " + actionType
        {}
  else
    newRecords = records.push(Immutable.List([actionType, actionData, actionMeta]))
    if core.get('isTravelling')
      records: newRecords
    else
      updateHandler = core.get 'updater'
      records: newRecords
      store: updateHandler core.get('store'), actionType, actionData, actionMeta

# exports methods

exports.setup = (options) ->
  core = core
  .merge Immutable.fromJS(options)
  .set 'store', options.initial

  if core.get('inProduction')
    setInterval ->
      if core.get('records').size > 40 and (not core.get('isTravelling'))
        exports.dispatch 'actions-recorder/commit'
    , (5 * 60 * 1000)

exports.hotSetup = (options) ->
  core = core.merge Immutable.fromJS(options)
  # getStoreFrom depends on updater, use mutable data to modify reference
  if core.get('isTravelling')
    records = core.get('records').slice(0, core.get('pointer'))
  else
    records = core.get('records')
  core = core.set 'store', getStoreFrom(records)

  recorderEmit()

exports.request = (fn) ->
  fn exports.getCore()

exports.getState = -> # deprecated
  exports.getStore()

exports.getStore = ->
  core.get('store')

exports.getCore = ->
  core.delete 'updater'

exports.subscribe = (fn) ->
  # bypass warning of "setState on unmounted component" with unshift
  recorderListeners = recorderListeners.unshift fn

exports.unsubscribe = (fn) ->
  recorderListeners = recorderListeners.filterNot (listener) ->
    listener is fn

exports.dispatch = (actionType, actionData, actionMeta) ->
  actionData = Immutable.fromJS(actionData)
  actionMeta = Immutable.fromJS(actionMeta)
  core = core.merge callUpdater(actionType, actionData, actionMeta)
  recorderEmit()
