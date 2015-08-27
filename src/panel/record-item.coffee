
React = require("react")
Immutable = require("immutable")
classnames = require("classnames")

div = React.createFactory("div")
pre = React.createFactory("pre")

module.exports = React.createClass
  displayName: "recorder-item"
  propTypes:
    index: React.PropTypes.number.isRequired
    record: React.PropTypes.instanceOf(Immutable.List)
    isPointer: React.PropTypes.bool.isRequired
    onPeek: React.PropTypes.func.isRequired

  onClick: ->
    @props.onPeek @props.index

  render: ->
    actionType = @props.record.get(0)
    actionData = @props.record.get(1)
    className = classnames "recorder-item",
      "is-pointer": @props.isPointer

    div className: className, onClick: @onClick,
      div className: "record-title", actionType
      pre className: "record-content",
        JSON.stringify(actionData, null, 2)
