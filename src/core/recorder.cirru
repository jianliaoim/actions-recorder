
var
  Emitter $ require :component-emitter
  Immutable $ require :immutable

var recorderOptions $ {}
  :inProduction true

var core $ {}
  :inital (Immutable.Map)
  :updater $ \ (store)
    console.warn ":Default recorder updater is called."
    return store

= exports.setup $ \ (inital updater mode)
  = core $ {}
    :inital inital
    :records (Immutable.List)
    :updater updater
    :pointer -1
  = recorderEmitter.inProduction $ or mode false

var recorderEmitter $ new Emitter

= exports.subscribe $ \ (fn)
  recorderEmitter.on :update fn

= exports.unsubscribe $ \ (fn)
  recorderEmitter.off :update fn

= exports.dispatch $ \ (actionType actionData)
  if recorderOptions.inProduction
    do
      callUpdaterInProduction actionType actionData
    do
      callUpdater actionType actionData
  return

var callUpdaterInProduction $ \ (actionType actionData)
  = actionData $ Immutable.fromJS actionData
  var newStore
    core.updater core.inital actionType actionData
  = core.inital newStore
  = core.records $ core.records.push
    Immutable.List actionType actionData
  recorderEmitter.emit :update newStore
    , core.records core.pointer

var callUpdater $ \ (actionType actionData)
  = actionData $ Immutable.fromJS actionData
  var chunks $ actionType.split :/
  var groupName $ . chunks 0
  if (is groupName :actions-recorder)
    do $ switch (. chunks 1)
      :commit
        var newStore $ core.records.reduce
          \ (acc action)
            core.updater acc (. action 0) (. action 1)
          , core.inital
        = core.inital newStore
        = core.records (Immutable.List)
        = core.pointer -1
        recorderEmitter.emit :update newStore core.records core.pointer
      :reset
        = core.records (Immutable.List)
        = core.pointer -1
        recorderEmitter.emit :update newStore core.records core.pointer
      :peek
        = core.pointer actionData
        var activeRecords $ core.records.slice 0 core.pointer
        var newStore $ activeRecords.reduce
          \ (acc action)
            core.updater acc (. action 0) (. action 1)
          , core.inital
        recorderEmitter.emit :update newStore core.records core.pointer
      :discard
        = core.records $ core.records.slice 0 core.pointer
        var newStore $ core.records.reduce
          \ (acc action)
            core.updater acc (. action 0) (. action 1)
          , core.inital
        recorderEmitter.emit :update newStore core.records core.pointer
      else
        console.warn $ + ":Unknown actions-recorder action: " actionType
    else
      emitUpdate actionType actionData

var emitUpdate $ \ (actionType actionData)
  = core.records $ core.records.push
    Immutable.List actionType actionData
  var newStore $ core.records.reduce
    \ (acc action)
      core.updater acc (. action 0) (. action 1)
    , core.inital
  recorderEmitter.emit :update newStore
    , core.records core.pointer
