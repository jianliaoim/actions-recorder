
React Actions Recorder, inspired by Redux
----

Demo http://ui.talk.ai/actions-recorder/

Tricks:

* Click with "Shift" key pressing to step backward.
* set `inProduction` true if you want to limit size of `records` to `400`

### Chinese Guide

* [用 React Actions Recorder 作为 Store 写 Todolist](http://segmentfault.com/a/1190000003863338)

### Usage

```bash
npm i --save actions-recorder
```

Get `recorder`:

```coffee
recorder = require 'actions-recorder'
```

Get Devtools:

```coffee
# for component
Devtools = require 'actions-recorder/lib/devtools'
```

`recorder` has methods:

* `recorder.setup(options)`
* `recorder.hotSetup(options)`
* `recorder.getStore()`
* `recorder.getCore()`
* `recorder.request (core) ->`
* `recorder.subscribe (core) ->`
* `recorder.unsubscribe(listener)`
* `recorder.dispatch(actionType, actionData)`

You will need `recorder.getState()` or `core.get('store')` to find store.

`Devtools` is a component to show actions:

```coffee
React.createElement Devtools,
  core: core # internal data from recorder
  width: window.innerWidth
  height: window.innerHeight # flexbox not powerful enough, use JavaScript
  path: @state.path # path of JSON tree reader, use `Immutable.List()` as default
  onPathChange: (newPath) -> @setState path: newPath
```

Read code in `src/` to get more details.

### Basic Hot Module Replacement support

`.hotSetup()` is used in hot replacing `updater` and `initial`:

```coffee
if module.hot
  module.hot.accept ['./updater', './schema'], ->
    schema = require './schema'
    updater = require './updater'
    recorder.hotSetup
      initial: schema.store
      updater: updater
```

Also read `src/` for details. By now there's only basic support for HMR.

### Background Image

http://www.fabuloussavers.com/new_wallpaper/DJ_Vinyl_Disc_freecomputerdesktopwallpaper_1920.jpg

### Development

```bash
gulp html # generates index.html
webpack-dev-server --hot --host=0.0.0.0
```

### License

MIT
