
React = require("react")
Immutable = require("immutable")
classnames = require("classnames")

actions = require("../actions")

div = React.createFactory("div")
input = React.createFactory("input")

module.exports = React.createClass
  displayName: "app-todolist"
  propTypes:
    store: React.PropTypes.instanceOf(Immutable.List)

  onAdd: onAdd = ->
    actions.add()

  rendeTask: rendeTask = (task) ->
    onToggle = onToggle = ->
      actions.toggle task.get("id")

    onUpdate = onUpdate = (event) ->
      actions.update task.get("id"), event.target.value

    onRemove = onRemove = ->
      actions.remove task.get("id")

    checkboxClassName = classnames "checkbox",
      "is-checked": task.get("done")

    div className: "todolist-task line", key: task.get("id"),
      div className: checkboxClassName, onClick: onToggle
      input type: "text", value: task.get("text"), onChange: onUpdate
      div className: "button is-danger", onClick: onRemove, "Remove"

  render: render = ->
    div className: "app-todolist",
      div className: "todolist-header",
        div className: "button is-attract", onClick: @onAdd, "Add"
      div className: "todolist-table",
        @props.store.map(@rendeTask)
