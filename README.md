
Actions Recorder(a Redux clone for learning purpose)
----

This project is not tested. I'll add a blog as introduction later.

Demo http://repo.tiye.me/actions-recorder/

### Usage

```
npm i --save actions-recorder
```
```coffee
{recorder, recorderController} = require 'actions-recorder'
```

`recorder` is a mutable object like store, with methods:

* `recorder.setup (inital updater mode) ->`
* `recorder.subscribe (store recorder) ->`
* `recorder.ubsubscribe (store listener)`
* `recorder.dispatch (actionType actionData)`

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
