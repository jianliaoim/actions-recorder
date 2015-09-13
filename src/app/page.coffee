
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
        records: @props.recorder.records
        pointer: @props.recorder.pointer
        initial: @props.recorder.initial
        updater: @props.recorder.updater
        isTravelling: @props.recorder.isTravelling
        onCommit: @onCommit
        onReset: @onReset
        onPeek: @onPeek
        onRun: @onRun
        onMergeBefore: @onMergeBefore
        onClearAfter: @onClearAfter
        language: 'zh'
