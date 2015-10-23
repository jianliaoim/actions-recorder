
diff = require 'immutablediff'
React = require 'react'
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

  propTypes:
    core: React.PropTypes.instanceOf(Immutable.Map).isRequired
    language: React.PropTypes.string
    dispatch: React.PropTypes.func
    width: React.PropTypes.number.isRequired
    height: React.PropTypes.number.isRequired

  getDefaultProps: ->
    language: 'en'

  getInitialState: ->
    tab: 'action' # ['action', 'store', 'diff']

  getStoreAtPointer: (pointer) ->
    core = @props.core
    if pointer < 1
      core.get('initial')
    else
      updater = (acc, record) =>
        core.get('updater') acc, record.get(0), record.get(1)
      core.get('records').slice(0, pointer).reduce updater, core.get('initial')

  dispatch: (actionName, actionData) ->
    if @props.dispatch?
      @props.dispatch actionName, actionData
    else
      recorder.dispatch actionName, actionData

  onTabSelect: (name) ->
    @setState tab: name

  onCommit: ->
    @dispatch "actions-recorder/commit"

  onReset: ->
    @dispatch "actions-recorder/reset"

  onPeek: (position) ->
    @dispatch "actions-recorder/peek", position

  onRun: ->
    @dispatch "actions-recorder/run"

  onMergeBefore: ->
    if @props.core.get('pointer') > 0
      @dispatch "actions-recorder/merge-before"

  onClearAfter: ->
    @dispatch "actions-recorder/clear-after"

  onStep: (event) ->
    @dispatch 'actions-recorder/step', event.shiftKey

  onInitialClick: ->
    @dispatch 'actions-recorder/peek', 0

  renderItem: (record, originalIndex) ->
    core = @props.core
    index = core.get('records').size - originalIndex
    onClick = => @onPeek index
    isSelected = core.get('pointer') is index and core.get('isTravelling')
    div key: index, style: @styleItem(isSelected), onClick: onClick, record.get(0)

  renderAction: ->
    if @props.core.get('pointer') > 0
      record = @props.core.get('records').get(@props.core.get('pointer') - 1)
      actionData = record.get(1)
    else
      actionData = null
    Viewer key: @state.tab, height: (@props.height - 70), data: actionData

  renderStore: ->
    result = @getStoreAtPointer @props.core.get('pointer')
    Viewer key: @state.tab, height: (@props.height - 70), data: result

  renderDiff: ->
    core = @props.core
    result = @getStoreAtPointer core.get('pointer')
    prevResult = @getStoreAtPointer (core.get('pointer') - 1)
    try
      changes = diff prevResult, result
    catch error
      changes = error
    Viewer key: @state.tab, height: (core.get('height') - 70), data: changes

  renderCurrent: ->
    core = @props.core
    store = core.get('cachedStore')
    Viewer key: @state.tab, height: (core.get('height') - 70), data: store

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
    core = @props.core
    hint = (text) => locale.get(text, @props.language)
    isInitialSelected = core.get('pointer') is 0 and core.get('isTravelling')
    records = core.get('records')
    isTravelling = core.get('isTravelling')

    showMergeBefore = core.get('pointer') > 0 and isTravelling
    showClearAfter = core.get('pointer') < records.size and isTravelling
    showReset = records.size > 0
    showCommit = records.size > 0
    showRun = isTravelling
    showStep = isTravelling and records.size > 0

    div style: @styleRoot(),
      div style: @styleHeader(),
        div style: @styleButton(showMergeBefore), onClick: @onMergeBefore, hint 'mergeBefore'
        div style: @styleButton(showClearAfter), onClick: @onClearAfter, hint 'clearAfter'
        div style: @styleButton(showReset), onClick: @onReset, hint 'reset'
        div style: @styleButton(showCommit), onClick: @onCommit, hint 'commit'
        div style: @styleButton(showRun), onClick: @onRun, hint 'run'
        div style: @styleButton(showStep), onClick: @onStep, hint 'step'
        div style: @styleTip(), "(#{core.get('pointer')}/#{core.get('records').size})"
      div style: @styleViewer(),
        div style: @styleMonitor(),
          core.get('records').reverse().map @renderItem
          div style: @styleItem(isInitialSelected), onClick: @onInitialClick, '__initial__'
        if core.get('isTravelling') and core.get('records').get(core.get('pointer') - 1)?
          @renderDetails()
        else
          @renderCurrent()

  styleRoot: ->
    background: 'hsla(0, 0%, 0%, 0.56)'
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
    fontSize: '12px'
    fontFamily: 'Verdana, Helvetica, sans-serif'
    lineHeight: '30px'
    cursor: 'pointer'

  styleEntry: (isSelected) ->
    display: 'inline-block'
    backgroundColor: if isSelected then 'hsla(0,100%,100%,0.5)' else 'hsla(0,100%,100%,0.2)'
    marginRight: '10px'
    padding: '0 10px'
    fontSize: '12px'
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
    paddingTop: '100px'
    paddingBottom: '100px'
    height: (@props.height - 40)

  styleItem: (isPointer) ->
    cursor: 'pointer'
    lineHeight: '30px'
    fontSize: '12px'
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
