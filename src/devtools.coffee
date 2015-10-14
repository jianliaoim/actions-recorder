
diff = require 'immutablediff'
React = require 'react/addons'
keycode = require 'keycode'
Immutable = require 'immutable'
classnames = require 'classnames'

recorder = require './recorder'

locale = require './app/locale'

Viewer = React.createFactory require './app/viewer'

{div, pre} = React.DOM

tabs = ['action', 'store', 'diff']

module.exports = React.createClass
  displayName: "actions-recorder-devtools"
  mixins: [React.addons.PureRenderMixin]

  propTypes:
    store: React.PropTypes.instanceOf(Immutable.Collection).isRequired
    records: React.PropTypes.instanceOf(Immutable.List).isRequired
    initial: React.PropTypes.instanceOf(Immutable.Collection).isRequired
    updater: React.PropTypes.func.isRequired
    pointer: React.PropTypes.number.isRequired
    isTravelling: React.PropTypes.bool.isRequired
    language: React.PropTypes.string
    width: React.PropTypes.number.isRequired
    height: React.PropTypes.number.isRequired

  getDefaultProps: ->
    language: 'en'

  getInitialState: ->
    tab: 'action' # ['action', 'store', 'diff']

  getStoreAtPointer: (pointer) ->
    if pointer < 1
      result = @props.initial
    else
      updater = (acc, record) =>
        @props.updater acc, record.get(0), record.get(1)
      result = @props.records.slice(0, pointer).reduce updater, @props.initial

  onTabSelect: (name) ->
    @setState tab: name

  onCommit: ->
    recorder.dispatch "actions-recorder/commit"

  onReset: ->
    recorder.dispatch "actions-recorder/reset"

  onPeek: (position) ->
    recorder.dispatch "actions-recorder/peek", position

  onRun: ->
    recorder.dispatch "actions-recorder/run"

  onMergeBefore: ->
    if @props.pointer > 0
      recorder.dispatch "actions-recorder/merge-before"

  onClearAfter: ->
    recorder.dispatch "actions-recorder/clear-after"

  onStep: (event) ->
    recorder.dispatch 'actions-recorder/step', event.shiftKey

  onInitialClick: ->
    recorder.dispatch 'actions-recorder/peek', 0

  renderItem: (record, originalIndex) ->
    index = originalIndex + 1
    onClick = => @onPeek index
    isSelected = @props.pointer is index and @props.isTravelling
    div key: index, style: @styleItem(isSelected), onClick: onClick, record.get(0)

  renderAction: ->
    if @props.pointer > 0
      record = @props.records.get(@props.pointer - 1)
      actionData = record.get(1)
    else
      actionData = null
    Viewer key: @state.tab, height: (@props.height - 70), data: actionData

  renderStore: ->
    result = @getStoreAtPointer @props.pointer
    Viewer key: @state.tab, height: (@props.height - 70), data: result

  renderDiff: ->
    result = @getStoreAtPointer @props.pointer
    prevResult = @getStoreAtPointer (@props.pointer - 1)
    try
      changes = diff prevResult, result
    catch error
      changes = error
    Viewer key: @state.tab, height: (@props.height - 70), data: changes

  renderCurrent: ->
    Viewer key: @state.tab, height: (@props.height - 70), data: @props.store

  renderDetails: ->
    div style: @styleDetails(),
      div style: @styleMode(),
        tabs.map (name) =>
          onClick = => @onTabSelect name
          div style: @styleEntry(name is @state.tab), onClick: onClick, key: name, name
      switch @state.tab
        when 'action' then @renderAction()
        when 'store' then @renderStore()
        when 'diff' then @renderDiff()

  render: ->
    hint = (text) =>
      locale.get(text, @props.language)
    isInitialSelected = @props.pointer is 0 and @props.isTravelling

    showMergeBefore = @props.pointer > 0 and @props.isTravelling
    showClearAfter = @props.pointer < @props.records.size and @props.isTravelling
    showReset = @props.records.size > 0
    showCommit = @props.records.size > 0
    showRun = @props.isTravelling
    showStep = @props.isTravelling and @props.records.size > 0

    div style: @styleRoot(),
      div style: @styleHeader(),
        div style: @styleButton(showMergeBefore), onClick: @onMergeBefore, hint 'mergeBefore'
        div style: @styleButton(showClearAfter), onClick: @onClearAfter, hint 'clearAfter'
        div style: @styleButton(showReset), onClick: @onReset, hint 'reset'
        div style: @styleButton(showCommit), onClick: @onCommit, hint 'commit'
        div style: @styleButton(showRun), onClick: @onRun, hint 'run'
        div style: @styleButton(showStep), onClick: @onStep, hint 'step'
        div style: @styleTip(), "(#{@props.pointer}/#{@props.records.size})"
      div style: @styleViewer(),
        div style: @styleMonitor(),
          div style: @styleItem(isInitialSelected), onClick: @onInitialClick, '__initial__'
          @props.records.map @renderItem
        if @props.isTravelling and @props.records.get(@props.pointer - 1)?
          @renderDetails()
        else
          @renderCurrent()

  styleRoot: ->
    background: 'hsla(0, 0%, 0%, 0.6)'
    color: 'white'
    fontFamily: 'Menlo, Consolas, Ubuntu Mono, monospace'
    lineHeight: '1.8em'
    display: 'flex'
    height: '100%'
    flexDirection: 'column'
    transitionProperty: 'left, top'
    transitionDuration: '300ms'
    zIndex: 9999
    flex: 1

  styleButton: (isAvailable) ->
    display: 'inline-block'
    backgroundColor: if isAvailable then 'hsla(0,100%,100%,0.2)' else 'hsla(0,100%,80%,0.2)'
    color: if isAvailable then 'white' else 'hsla(0,100%,100%,0.4)'
    marginRight: '10px'
    padding: '0 10px'
    fontSize: '14px'
    fontFamily: 'Verdana, Helvetica, sans-serif'
    lineHeight: '30px'
    cursor: 'pointer'

  styleEntry: (isSelected) ->
    display: 'inline-block'
    backgroundColor: if isSelected then 'hsla(0,100%,100%,0.5)' else 'hsla(0,100%,100%,0.2)'
    marginRight: '10px'
    padding: '0 10px'
    fontSize: '14px'
    fontFamily: 'Verdana, Helvetica, sans-serif'
    lineHeight: '30px'
    cursor: 'pointer'

  styleHeader: ->
    WebkitUserSelect: 'none'
    marginBottom: '10px'

  styleViewer: ->
    flex: 1
    display: 'flex'
    flexDirection: 'row'
    height: (@props.height - 40)
    position: 'relative'

  styleMonitor: ->
    width: 'auto'
    paddingRight: '40px'
    marginRight: '10px'
    overflowX: 'hidden'
    paddingBottom: '40px'
    height: (@props.height - 40)

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

  styleMode: ->
    height: '30px'
    flexDirection: 'row'

  styleTip: ->
    fontSize: '12px'
    display: 'inline-block'
