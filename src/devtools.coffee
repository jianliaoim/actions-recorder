
diff = require 'immutablediff'
React = require 'react/addons'
keycode = require 'keycode'
recorder = require './recorder'
Immutable = require("immutable")
classnames = require("classnames")

locale = require './app/locale'

div = React.createFactory("div")
pre = React.createFactory("pre")
input = React.createFactory("input")

span = document.createElement('span')
tabs = ['action', 'store', 'prev', 'diff']

module.exports = React.createClass
  displayName: "actions-recorder-devtools"
  mixins: [React.addons.PureRenderMixin]

  propTypes:
    records: React.PropTypes.instanceOf(Immutable.List)
    inital: React.PropTypes.instanceOf(Immutable.Map)
    updater: React.PropTypes.func.isRequired
    pointer: React.PropTypes.number.isRequired
    isTravelling: React.PropTypes.bool.isRequired
    language: React.PropTypes.string

  getDefaultProps: ->
    language: 'en'

  getInitialState: ->
    dataPath: ''
    x: 400
    y: 200
    tab: 'action' # ['action', 'prev', 'store', 'diff']

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

  onCommit: ->
    recorder.dispatch "actions-recorder/commit"

  onReset: ->
    recorder.dispatch "actions-recorder/reset"

  onPeek: (position) ->
    recorder.dispatch "actions-recorder/peek", position

  onRun: ->
    recorder.dispatch "actions-recorder/run"

  onMergeBefore: ->
    recorder.dispatch "actions-recorder/merge-before"

  onClearAfter: ->
    recorder.dispatch "actions-recorder/clear-after"

  renderItem: (record, index) ->
    onClick = => @onPeek index
    div key: index, style: @styleItem(@props.pointer is index), onClick: onClick, record.get(0)

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
      else if data?.get?
        piece = data.get(keys[0])
        if (not piece?) and (Immutable.List.isList data)
          piece = data.find (item) ->
            item.get('id') is keys[0] or item.get('_id') is keys[0]
        helper piece, keys.slice(1)
      else data
    JSON.stringify helper(result, dataPath), null, 2

  renderCurrent: ->
    updater = (acc, record) =>
      @props.updater acc, record.get(0), record.get(1)
    store = @props.records.reduce updater, @props.initial
    div style: @styleCurrent(),
      pre style: @styleData(),
        @renderResult store

  renderDetails: ->
    div style: @styleDetails(),
      div style: @styleMode(),
        tabs.map (name) =>
          onClick = => @onTabSelect name
          div style: @styleButton(name is @state.tab), onClick: onClick, key: name, name
      pre style: @styleData(),
        switch @state.tab
          when 'action' then @renderAction()
          when 'prev' then @renderPrev()
          when 'store' then @renderStore()
          when 'diff' then @renderDiff()

  render: ->
    hint = (text) =>
      locale.get(text, @props.language)

    div style: @styleRoot(),
      div style: @styleHeader(),
        div style: @styleButton(false), onClick: @onCommit,
          hint 'commit'
        div style: @styleButton(false), onClick: @onReset,
          hint 'reset'
        div style: @styleButton(false), onClick: @onMergeBefore,
          hint 'mergeBefore'
        div style: @styleButton(false), onClick: @onClearAfter,
          hint 'clearAfter'
        if @props.isTravelling
          div style: @styleButton(false), onClick: @onRun,
            hint 'run'
        input style: @styleInput(), value: @state.dataPath, onChange: @onChange, onKeyDown: @onKeyDown
      div style: @styleViewer(),
        div style: @styleMonitor(),
          @props.records.map @renderItem
        if @props.isTravelling and @props.records.get(@props.pointer)?
          @renderDetails()
        else
          @renderCurrent()

  styleRoot: ->
    top: @state.y
    left: @state.x
    width: '800px'
    height: '500px'
    position: 'fixed'
    top: '300px'
    left: '100px'
    background: 'hsla(240,60%,70%,0.8)'
    color: 'white'
    fontFamily: 'Menlo, Consolas, monospace'
    lineHeight: '1.8em'
    display: 'flex'
    flexDirection: 'column'
    transitionProperty: 'left top'
    transitionDuration: '300ms'
    zIndex: 9999

  styleButton: (isSelected) ->
    display: 'inline-block'
    backgroundColor: if isSelected then 'hsla(0,100%,100%,0.2)' else 'hsla(0,100%,100%,0.5)'
    marginRight: '10px'
    padding: '0 10px'
    fontSize: '14px'
    fontFamily: 'Verdana, Helvetica, sans-serif'
    lineHeight: '30px'
    cursor: 'pointer'

  styleHeader: ->
    WebkitUserSelect: 'none'
    marginBottom: '10px'

  styleInput: ->
    backgroundColor: 'hsla(240,70%,90%,0.1)'
    borderColor: 'hsla(0,100%,100%,0.8)'
    color: 'white'
    width: '300px'
    borderCtyle: 'solid'
    borderWidth: '0 0 1px 0'
    outline: 'none'
    fontFamily: 'Menlo, Consolas, monospace'
    fontSize: '13px'
    padding: '0 6px'

  styleViewer: ->
    flex: 1
    display: 'flex'
    flexDirection: 'row'

  styleMonitor: ->
    width: '250px'
    marginRight: '10px'
    overflowX: 'hidden'
    paddingBottom: '400px'

  styleItem: (isPointer) ->
    cursor: 'pointer'
    lineHeight: '30px'
    fontSize: '13px'
    padding: '0 10px'
    backgroundColor: if isPointer then 'hsla(0,100%,100%,0.2)' else 'transparent'

  styleDetails: ->
    flex: 1
    overflow: 'auto'
    display: 'flex'
    flexDirection: 'column'

  styleCurrent: ->
    flex: 1
    overflow: 'auto'

  styleMode: ->
    height: '30px'
    flexDirection: 'row'

  styleData: ->
    flex: 1
    fontSize: '12px'
    lineHeight: '16px'
    fontFamily: 'Menlo, Consolas, monospace'
