
React = require("react")
Immutable = require("immutable")

Todolist = React.createFactory(require("./todolist"))
Devtools = React.createFactory(require("../devtools"))

div = React.createFactory("div")

module.exports = React.createClass
  displayName: "app-page"
  propTypes:
    store: React.PropTypes.instanceOf(Immutable.List)
    core: React.PropTypes.object.isRequired

  render: render = ->
    core = @props.core

    div className: "app-page",
      Todolist(store: @props.store)
      Devtools
        store: @props.store
        records: core.records
        pointer: core.pointer
        initial: core.initial
        updater: core.updater
        cachedStore: core.cachedStore
        isTravelling: core.isTravelling
        language: 'en'
