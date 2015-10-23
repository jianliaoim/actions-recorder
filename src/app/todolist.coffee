
React = require("react")
Immutable = require("immutable")
classnames = require("classnames")

actions = require("../actions")

{div, a, input} = React.DOM
repo = 'https://github.com/teambition/actions-recorder'

module.exports = React.createClass
  displayName: "app-todolist"
  propTypes:
    store: React.PropTypes.instanceOf(Immutable.List)

  onAdd: onAdd = ->
    actions.add()

  rendeTask: (task) ->
    onToggle = ->
      actions.toggle task.get("id")

    onUpdate = (event) ->
      actions.update task.get("id"), event.target.value

    onRemove = ->
      actions.remove task.get("id")

    checkboxClassName = classnames "checkbox",
      "is-checked": task.get("done")

    div className: "todolist-task line", key: task.get("id"),
      div className: checkboxClassName, onClick: onToggle
      input type: "text", value: task.get("text"), onChange: onUpdate
      div className: "button is-danger", onClick: onRemove, "Remove"

  renderNote: ->
    div className: 'note',
      a href: repo, "Demo of actions-recorder, find more on GitHub."

  render: render = ->
    div className: "app-todolist",
      @renderNote()
      div className: "todolist-table",
        @props.store.map(@rendeTask)
      div className: "todolist-footer",
        div className: "button is-attract", onClick: @onAdd, "Add"
