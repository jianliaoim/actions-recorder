
diff = require 'immutablediff'
React = require("react")
keycode = require 'keycode'
Immutable = require("immutable")
classnames = require("classnames")

locale = require './locale'

div = React.createFactory("div")
pre = React.createFactory("pre")
input = React.createFactory("input")

span = document.createElement('span')
tabs = ['action', 'store', 'prev', 'diff']

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
    language: React.PropTypes.string

  getDefaultProps: ->
    language: 'en'

  getInitialState: ->
    dataPath: ''
    x: 0
    y: 0
    tab: 'prev' # ['action', 'prev', 'store', 'diff']

  onChange: (event) ->
    @setState dataPath: event.target.value

  onTabSelect: (name) ->
    @setState tab: name

  onKeyDown: (event) ->
    if event.metaKey and event.ctrlKey
      switch keycode(event.keyCode)
        when 'left' then @setState x: @state.x - 200
        when 'right' then @setState x: @state.x + 200
        when 'up' then @setState y: @state.y - 200
        when 'down' then @setState y: @state.y + 200

  renderItem: (record, index) ->
    onClick = =>
      @props.onPeek index
    className = classnames "recorder-item",
      "is-pointer": @props.isTravelling and @props.pointer is index

    div key: index, className: className, onClick: onClick, record.get(0)

  renderAction: ->
    record = @props.records.get(@props.pointer)
    JSON.stringify record.get(1), null, 2

  renderPrev: ->
    updater = (acc, record) =>
      @props.updater acc, record.get(0), record.get(1)
    result = @props.records.slice(0, @props.pointer).reduce updater, @props.initial
    @renderResult(result)

  renderStore: ->
    updater = (acc, record) =>
      @props.updater acc, record.get(0), record.get(1)
    result = @props.records.slice(0, @props.pointer + 1).reduce updater, @props.initial
    @renderResult(result)

  renderDiff: ->
    updater = (acc, record) =>
      @props.updater acc, record.get(0), record.get(1)
    prevResult = @props.records.slice(0, @props.pointer).reduce updater, @props.initial
    result = @props.records.slice(0, @props.pointer + 1).reduce updater, @props.initial
    changes = diff prevResult, result
    JSON.stringify changes, null, 2

  renderResult: (result) ->
    dataPath = @state.dataPath.split(/\s+/).filter (chunk) ->
      chunk.length > 0
    helper = (data, keys) ->
      if keys.length is 0
        data
      else
        try helper data.get(keys[0]), keys.slice(1)
    JSON.stringify helper(result, dataPath), null, 2

  renderDetails: ->
    div className: "recorder-details",
      div className: 'recorder-mode',
        tabs.map (name) =>
          tabClass = classnames 'tap-button', 'is-selected': (name is @state.tab)
          onClick = => @onTabSelect name
          div className: tabClass, onClick: onClick, key: name, name
      pre className: 'recorder-data',
        switch @state.tab
          when 'action' then @renderAction()
          when 'prev' then @renderPrev()
          when 'store' then @renderStore()
          when 'diff' then @renderDiff()

  render: ->
    style = {top: @state.y, left: @state.x}

    div className: "recorder-controller", style: style,
      div className: "recorder-header",
        div className: "tap-button", onClick: @props.onCommit,
          locale.get('commit', @props.language)
        div className: "tap-button", onClick: @props.onReset,
          locale.get('reset', @props.language)
        div className: "tap-button", onClick: @props.onMergeBefore,
          locale.get('mergeBefore', @props.language)
        div className: "tap-button", onClick: @props.onClearAfter,
          locale.get('clearAfter', @props.language)
        if @props.isTravelling
          div className: "tap-button", onClick: @props.onRun,
            locale.get('run', @props.language)
        input value: @state.dataPath, onChange: @onChange, onKeyDown: @onKeyDown
      div className: 'recorder-viewer',
        div className: "recorder-monitor",
          @props.records.map @renderItem
        if @props.isTravelling and @props.records.get(@props.pointer)?
          @renderDetails()
