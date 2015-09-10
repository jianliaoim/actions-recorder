
React = require("react")
Immutable = require("immutable")
classnames = require("classnames")

div = React.createFactory("div")
pre = React.createFactory("pre")
input = React.createFactory("input")

module.exports = React.createClass
  displayName: "actions-recorder-controller"
  propTypes:
    records: React.PropTypes.instanceOf(Immutable.List)
    inital: React.PropTypes.instanceOf(Immutable.Map)
    updater: React.PropTypes.func.isRequired
    pointer: React.PropTypes.number.isRequired
    isTravelling: React.PropTypes.bool.isRequired
    onCommit: React.PropTypes.func.isRequired
    onSwitch: React.PropTypes.func.isRequired
    onReset: React.PropTypes.func.isRequired
    onPeek: React.PropTypes.func.isRequired
    onDiscard: React.PropTypes.func.isRequired

  getInitialState: ->
    dataPath: ''

  onChange: (event) ->
    @setState dataPath: event.target.value

  renderItem: (record, index) ->
    onClick = =>
      @props.onPeek index
    className = classnames "recorder-item",
      "is-pointer": @props.isTravelling and @props.pointer is index

    div className: className, onClick: onClick, record.get(0)

  renderAction: ->
    record = @props.records.get(@props.pointer)
    pre className: 'recorder-action-data',
      JSON.stringify record.get(1), null, 2

  renderPrev: ->
    updater = (acc, record) =>
      @props.updater acc, record.get(0), record.get(1)
    result = @props.records.slice(0, @props.pointer).butLast().reduce updater, @props.initial
    pre className: 'recorder-prev',
      @renderResult(result)

  renderStore: ->
    updater = (acc, record) =>
      @props.updater acc, record.get(0), record.get(1)
    result = @props.records.slice(0, @props.pointer).reduce updater, @props.initial
    pre className: 'recorder-store',
      @renderResult(result)

  renderResult: (result) ->
    dataPath = @state.dataPath.split(/\s+/).filter (chunk) ->
      chunk.length > 0
    helper = (data, keys) ->
      if keys.length is 0
        data
      else
        try helper data.get(keys[0]), keys.slice(1)
    JSON.stringify helper(result, dataPath), null, 2

  render: ->
    div className: "recorder-controller",
      div className: "recorder-header line",
        div className: "button is-attract", onClick: @props.onCommit, "Commit"
        div className: "button is-attract", onClick: @props.onSwitch,
          if @props.isTravelling then "Back" else "Travel"
        div className: "button is-danger", onClick: @props.onDiscard, "Discard"
        div className: "button is-danger", onClick: @props.onReset, "Reset"
        input value: @state.dataPath, onChange: @onChange
      div className: 'recorder-viewer',
        div className: "recorder-monitor",
          @props.records.map @renderItem
        if @props.records.get(@props.pointer)?
          div className: "recorder-details",
            @renderPrev()
            @renderAction()
            @renderStore()
