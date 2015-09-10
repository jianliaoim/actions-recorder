
React = require("react")
Immutable = require("immutable")
classnames = require("classnames")

locale = require './locale'

div = React.createFactory("div")
pre = React.createFactory("pre")
input = React.createFactory("input")

span = document.createElement('span')

module.exports = React.createClass
  displayName: "actions-recorder-controller"
  propTypes:
    records: React.PropTypes.instanceOf(Immutable.List)
    inital: React.PropTypes.instanceOf(Immutable.Map)
    updater: React.PropTypes.func.isRequired
    pointer: React.PropTypes.number.isRequired
    isTravelling: React.PropTypes.bool.isRequired
    onCommit: React.PropTypes.func.isRequired
    onReset: React.PropTypes.func.isRequired
    onPeek: React.PropTypes.func.isRequired
    onMergeBefore: React.PropTypes.func.isRequired
    onClearAfter: React.PropTypes.func.isRequired
    onRun: React.PropTypes.func.isRequired
    language: React.string

  getDefaultProps: ->
    language: 'en'
    isDragging: false
    x: 100
    y: 100

  getInitialState: ->
    dataPath: ''

  componentDidMount: ->
    window.addEventListener 'dragover', @onMove

  componentWillUnmount: ->
    window.removeEventListener 'dragover', @onMove

  onChange: (event) ->
    @setState dataPath: event.target.value

  onDragStart: (event) ->
    event.dataTransfer.setDragImage span, 0, 0
    @setState isDragging: true

  onDragEnd: (event) ->
    @setState isDragging: false

  onMove: (event) ->
    @setState x: (event.pageX - 400), y: (event.pageY - 250)

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
    div
      className: "recorder-controller", draggable: true
      onDragStart: @onDragStart, onDragEnd: @onDragEnd
      style: {top: @state.y, left: @state.x}
      div className: "recorder-header line",
        div className: "button is-attract", onClick: @props.onCommit,
          locale.get('commit', @props.language)
        div className: "button is-danger", onClick: @props.onReset,
          locale.get('reset', @props.language)
        div className: "button is-attract", onClick: @props.onMergeBefore,
          locale.get('mergeBefore', @props.language)
        div className: "button is-danger", onClick: @props.onClearAfter,
          locale.get('clearAfter', @props.language)
        if @props.isTravelling
          div className: "button is-attract", onClick: @props.onRun,
            locale.get('run', @props.language)
        input value: @state.dataPath, onChange: @onChange
      div className: 'recorder-viewer',
        div className: "recorder-monitor",
          @props.records.map @renderItem
        if @props.isTravelling and @props.records.get(@props.pointer)?
          div className: "recorder-details",
            @renderPrev()
            @renderAction()
            @renderStore()
