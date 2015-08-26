
var
  Emitter $ require :component-emitter
  Immutable $ require :immutable

var core $ {}
  :records (Immutable.List)
  :pointer 0
  :isTravelling false
  :initial (Immutable.Map)
  :updater $ \ (state) state
  :inProduction false

= exports.setup $ \ (initial updater mode)
  = core.initial initial
  = core.updater updater
  = core.inProduction $ or mode false

var recorderEmitter $ new Emitter

= exports.subscribe $ \ (fn)
  recorderEmitter.on :update fn

= exports.unsubscribe $ \ (fn)
  recorderEmitter.off :update fn

= exports.dispatch $ \ (actionType actionData)
  if core.inProduction
    do
      callUpdaterInProduction actionType actionData
    do
      callUpdater actionType actionData
  return

var callUpdaterInProduction $ \ (actionType actionData)
  = actionData $ Immutable.fromJS actionData
  var newStore
    core.updater core.initial actionType actionData
  = core.initial newStore
  = core.records $ core.records.push
    Immutable.List $ [] actionType actionData
  recorderEmitter.emit :update newStore core

var callUpdater $ \ (actionType actionData)
  = actionData $ Immutable.fromJS actionData
  var chunks $ actionType.split :/
  var groupName $ . chunks 0
  if (is groupName :actions-recorder)
    do $ switch (. chunks 1)
      :commit
        = core.initial $ core.records.reduce
          \ (acc action)
            core.updater acc (action.get 0) (action.get 1)
          , core.initial
        = core.records (Immutable.List)
        = core.pointer 0
        = core.isTravelling false
        emitUpdate
      :reset
        = core.records (Immutable.List)
        = core.pointer 0
        = core.isTravelling false
        emitUpdate
      :peek
        = core.pointer actionData
        = core.isTravelling true
        var activeRecords $ core.records.slice 0 core.pointer
        emitUpdate
      :discard
        = core.records $ core.records.slice 0 $ + core.pointer 1
        emitUpdate
      :switch
        = core.isTravelling $ not core.isTravelling
        = core.pointer 0
        emitUpdate
      else
        console.warn $ + ":Unknown actions-recorder action: " actionType
    do
      = core.records $ core.records.push
        Immutable.List $ [] actionType actionData
      emitUpdate
  return undefined

var emitUpdate $ \ ()
  var newStore $ cond
    and core.isTravelling (>= core.pointer 0)
    ... core.records
      slice 0 $ + core.pointer 1
      reduce
        \ (acc action)
          core.updater acc (action.get 0) (action.get 1)
        , core.initial
    core.records.reduce
      \ (acc action)
        core.updater acc (action.get 0) (action.get 1)
      , core.initial

  recorderEmitter.emit :update newStore core
