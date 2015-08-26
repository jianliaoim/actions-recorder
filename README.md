
Actions Recorder(a Redux clone for learning purpose)
----

This project is not tested. I'll add a blog as introduction later.

Demo http://repo.tiye.me/actions-recorder/

Buttons:

* Travel/Back: turn on/off debugger
* Commit: merge actions in records into initial state
* Reset: clear records
* Discard: clear records after current pointer
* <Click on Record>: set pointer to a record

### Usage

```
npm i --save actions-recorder
```

Get `recorder`:

```coffee
recorder = require 'actions-recorder'
```

Get controller in Webpack:

```coffee
# for component
recorderController = require 'actions-recorder/lib/panel/controller'
# for styles
require 'actions-recorder/style/actions-recorder.css'
```

`recorder` is a mutable object like store, with methods:

* `recorder.setup (options)`
* `recorder.request (store, recorder) ->`
* `recorder.subscribe (store, recorder) ->`
* `recorder.ubsubscribe (listener)`
* `recorder.dispatch (actionType, actionData)`

`recorderController` is a component to show actions:

```coffee
React.createElement recorderController,
  records: Immutable.List()
  pointer: 0
  isTravelling: false
  onReset: ->
  onCommit: ->
  onPeek: (position) ->
  onDiscard: ->
```

Read code in `src/` to get more details. Or read compiled JavaScipt:

```
npm i
gulp script # generated at `lib/`
```

### Development

https://github.com/mvc-works/webpack-workflow

### License

MIT
