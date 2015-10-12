
diff = require 'immutablediff'
React = require 'react/addons'
keycode = require 'keycode'
Immutable = require 'immutable'
classnames = require 'classnames'

recorder = require './recorder'

locale = require './app/locale'

Viewer = React.createFactory require './app/viewer'

{div, pre} = React.DOM

tabs = ['action', 'store', 'prev', 'diff']

module.exports = React.createClass
  displayName: "actions-recorder-devtools"
  mixins: [React.addons.PureRenderMixin]

  propTypes:
    store: React.PropTypes.instanceOf(Immutable.Collection).isRequired
    records: React.PropTypes.instanceOf(Immutable.List).isRequired
    inital: React.PropTypes.instanceOf(Immutable.Map).isRequired
    updater: React.PropTypes.func.isRequired
    pointer: React.PropTypes.number.isRequired
    isTravelling: React.PropTypes.bool.isRequired
    language: React.PropTypes.string
    width: React.PropTypes.number
    height: React.PropTypes.number

  getDefaultProps: ->
    language: 'en'
    width: window.innerWidth
    height: window.innerHeight

  getInitialState: ->
    tab: 'action' # ['action', 'prev', 'store', 'diff']

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
    recorder.dispatch "actions-recorder/merge-before"

  onClearAfter: ->
    recorder.dispatch "actions-recorder/clear-after"

  renderItem: (record, index) ->
    onClick = => @onPeek index
    div key: index, style: @styleItem(@props.pointer is index), onClick: onClick, record.get(0)

  renderAction: ->
    record = @props.records.get(@props.pointer)
    Viewer height: (@props.height - 40), data: record.get(1)

  renderPrev: ->
    updater = (acc, record) =>
      @props.updater acc, record.get(0), record.get(1)
    result = @props.records.slice(0, @props.pointer).reduce updater, @props.initial
    Viewer height: (@props.height - 40), data: result

  renderStore: ->
    updater = (acc, record) =>
      @props.updater acc, record.get(0), record.get(1)
    result = @props.records.slice(0, @props.pointer + 1).reduce updater, @props.initial
    Viewer height: (@props.height - 40), data: result

  renderDiff: ->
    updater = (acc, record) =>
      @props.updater acc, record.get(0), record.get(1)
    prevResult = @props.records.slice(0, @props.pointer).reduce updater, @props.initial
    result = @props.records.slice(0, @props.pointer + 1).reduce updater, @props.initial
    changes = diff prevResult, result
    Viewer height: (@props.height - 40), data: changes

  renderCurrent: ->
    Viewer height: (@props.height - 40), data: @props.store

  renderDetails: ->
    div style: @styleDetails(),
      div style: @styleMode(),
        tabs.map (name) =>
          onClick = => @onTabSelect name
          div style: @styleButton(name is @state.tab), onClick: onClick, key: name, name
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
        div style: @styleButton(false), onClick: @onCommit, hint 'commit'
        div style: @styleButton(false), onClick: @onReset, hint 'reset'
        div style: @styleButton(false), onClick: @onMergeBefore, hint 'mergeBefore'
        div style: @styleButton(false), onClick: @onClearAfter, hint 'clearAfter'
        if @props.isTravelling
          div style: @styleButton(false), onClick: @onRun, hint 'run'
      div style: @styleViewer(),
        div style: @styleMonitor(),
          @props.records.map @renderItem
        if @props.isTravelling and @props.records.get(@props.pointer)?
          @renderDetails()
        else
          @renderCurrent()

  styleRoot: ->
    background: 'hsla(200,60%,40%,0.8)'
    color: 'white'
    fontFamily: 'Menlo, Consolas, monospace'
    lineHeight: '1.8em'
    display: 'flex'
    height: '100%'
    flexDirection: 'column'
    transitionProperty: 'left, top'
    transitionDuration: '300ms'
    zIndex: 9999
    position: 'absolute'
    width: '100%'
    height: '100%'

  styleButton: (isSelected) ->
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
    width: '250px'
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
