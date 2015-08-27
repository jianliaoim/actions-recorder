
React = require("react")
Immutable = require("immutable")

actions = require("../actions")

Todolist = React.createFactory(require("./todolist"))
Controller = React.createFactory(require("../panel/controller"))

div = React.createFactory("div")

module.exports = React.createClass
  displayName: "app-page"
  propTypes:
    store: React.PropTypes.instanceOf(Immutable.List)
    recorder: React.PropTypes.object.isRequired

  onCommit: onCommit = ->
    actions.internalCommit()

  onSwitch: onSwitch = ->
    actions.internalSwitch()

  onReset: onReset = ->
    actions.internalReset()

  onPeek: onPeek = (position) ->
    actions.internalPeek position

  onDiscard: onDiscard = ->
    actions.internalDiscard()

  render: render = ->
    div className: "app-page",
      Todolist(store: @props.store)
      Controller
        records: @props.recorder.records
        pointer: @props.recorder.pointer
        isTravelling: @props.recorder.isTravelling
        onCommit: @onCommit
        onSwitch: @onSwitch
        onReset: @onReset
        onPeek: @onPeek
        onDiscard: @onDiscard
