
React = require("react")
Immutable = require("immutable")

Todolist = React.createFactory(require("./todolist"))
Controller = React.createFactory(require("../panel/controller"))

div = React.createFactory("div")

module.exports = React.createClass
  displayName: "app-page"
  propTypes:
    store: React.PropTypes.instanceOf(Immutable.List)
    core: React.PropTypes.object.isRequired

  render: render = ->
    div className: "app-page",
      Todolist(store: @props.store)
      Controller
        records: @props.core.records
        pointer: @props.core.pointer
        initial: @props.core.initial
        updater: @props.core.updater
        isTravelling: @props.core.isTravelling
        language: 'en'
