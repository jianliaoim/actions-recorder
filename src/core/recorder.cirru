
var
  assign $ require :object-assign
  Emitter $ require :component-emitter
  Immutable $ require :immutable

var core $ {}
  :records (Immutable.List)
  :pointer 0
  :isTravelling false
  :initial (Immutable.Map)
  :updater $ \ (state) state
  :inProduction false

var recorderEmitter $ new Emitter

var callUpdater $ \ (actionType actionData)
  var chunks $ actionType.split :/
  var groupName $ . chunks 0
  cond (is groupName :actions-recorder)
    case (. chunks 1)
      :commit $ {}
        :initial $ core.records.reduce
          \ (acc action)
            core.updater acc (action.get 0) (action.get 1)
          , core.initial
        :records (Immutable.List)
        :pointer 0
        :isTravelling false
      :reset $ {}
        :records (Immutable.List)
        :pointer 0
        :isTravelling false
      :peek $ {}
        :pointer actionData
        :isTravelling true
      :discard $ {}
        :records $ core.records.slice 0 $ + core.pointer 1
      :switch $ {}
        :isTravelling $ not core.isTravelling
        :pointer 0
      else
        console.warn $ + ":Unknown actions-recorder action: " actionType
        {}
    {}
      :records $ core.records.push
        Immutable.List $ [] actionType actionData

var getNewStore $ \ ()
  cond
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

= exports.setup $ \ (options)
  assign core options

= exports.request $ \ (fn)
  fn (getNewStore) core

= exports.subscribe $ \ (fn)
  recorderEmitter.on :update fn

= exports.unsubscribe $ \ (fn)
  recorderEmitter.off :update fn

= exports.dispatch $ \ (actionType actionData)
  = actionData $ Immutable.fromJS actionData
  if core.inProduction
    do
      = core.initial
        core.updater core.initial actionType actionData
      = core.records $ core.records.push
        Immutable.List $ [] actionType actionData
      recorderEmitter.emit :update core.initial core
    do
      assign core $ callUpdater actionType actionData
      recorderEmitter.emit :update (getNewStore) core
  return
