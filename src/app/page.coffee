
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
    core: React.PropTypes.object.isRequired

  onCommit: onCommit = ->
    actions.internalCommit()

  onReset: ->
    actions.internalReset()

  onPeek: (position) ->
    actions.internalPeek position

  onRun: ->
    actions.internalRun()

  onMergeBefore: ->
    actions.internalMergeBefore()

  onClearAfter: ->
    actions.internalClearAfter()

  render: render = ->
    div className: "app-page",
      Todolist(store: @props.store)
      Controller
        records: @props.core.records
        pointer: @props.core.pointer
        initial: @props.core.initial
        updater: @props.core.updater
        isTravelling: @props.core.isTravelling
        onCommit: @onCommit
        onReset: @onReset
        onPeek: @onPeek
        onRun: @onRun
        onMergeBefore: @onMergeBefore
        onClearAfter: @onClearAfter
        language: 'en'
