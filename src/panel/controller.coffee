
React = require("react")
Immutable = require("immutable")

RecordItem = React.createFactory(require("./record-item"))
div = React.createFactory("div")

module.exports = React.createClass
  displayName: "actions-recorder-controller"
  propTypes:
    records: React.PropTypes.instanceOf(Immutable.List)
    pointer: React.PropTypes.number.isRequired
    isTravelling: React.PropTypes.bool.isRequired
    onCommit: React.PropTypes.func.isRequired
    onSwitch: React.PropTypes.func.isRequired
    onReset: React.PropTypes.func.isRequired
    onPeek: React.PropTypes.func.isRequired
    onDiscard: React.PropTypes.func.isRequired

  render: ->
    div className: "actions-recorder-controller",
      div
        className: "recorder-monitor"
        style:
          paddingBottom: innerHeight - 50
          height: innerHeight - 50
        @props.records.map (record, index) =>
          onClick = =>
            @props.onPeek index

          RecordItem
            onClick: onClick
            record: record
            key: index
            index: index
            isPointer: @props.isTravelling and @props.pointer is index
            onPeek: @props.onPeek

      div className: "recorder-footer",
        div className: "button is-attract", onClick: @props.onCommit, "Commit"
        div className: "button is-attract", onClick: @props.onSwitch,
          if @props.isTravelling then "Back" else "Travel"
        div className: "button is-danger", onClick: @props.onDiscard, "Discard"
        div className: "button is-danger", onClick: @props.onReset, "Reset"
