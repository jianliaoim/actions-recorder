
React = require 'react'
Color = require 'color'
Immutable = require 'immutable'

{div, span, pre} = React.DOM

module.exports = React.createClass
  displayName: 'recorder-viewer'

  propTypes:
    data: React.PropTypes.instanceOf(Immutable.Collection).isRequired

  getInitialState: ->
    path: []

  onKeyClick: (key) ->
    @setState path: @state.path.concat(key)

  onParentKeyClick: (key) ->
    @setState path: @state.path[...-1].concat(key)

  onPathClick: (index) ->
    @setState path: @state.path.slice(0, (index + 1))

  onPathRootClick: ->
    @setState path: []

  renderPath: ->
    div null,
      div style: @styleKey(), onClick: @onPathRootClick, '/'
      @state.path.map (key, index) =>
        onClick = => @onPathClick index
        span key: key, style: @styleKey(), onClick: onClick, key

  renderParentKeys: ->
    keys = []
    value = @props.data.getIn(@state.path[...-1])
    if @state.path.length > 0 and value? and (value instanceof Immutable.Collection)
      iterator = value.keys()
      while true
        result = iterator.next()
        if result.value?
          keys.push  result.value
        if result.done
          break
      div style: @styleEntries(),
        keys.map (entry) =>
          onClick = => @onParentKeyClick entry
          div key: entry, onClick: onClick,
            span style: @styleKey(), entry
    else
      undefined

  renderKeys: ->
    keys = []
    value = @props.data.getIn(@state.path)
    if value? and (value instanceof Immutable.Collection)
      iterator = value.keys()
      while true
        result = iterator.next()
        if result.value?
          keys.push  result.value
        if result.done
          break
      div style: @styleEntries(),
        keys.map (entry) =>
          onClick = => @onKeyClick entry
          div key: entry, onClick: onClick,
            span style: @styleKey(), entry
    else
      undefined

  renderValue: ->
    value = @props.data.getIn(@state.path)
    pre style: @styleValue(),
      JSON.stringify value, null, 2

  render: ->
    div style: @styleRoot(),
      @renderPath()
      div style: @styleTable(),
        @renderParentKeys()
        @renderKeys()
        @renderValue()

  styleRoot: ->
    flex: 1

  styleTable: ->
    display: 'flex'
    flexDirection: 'row'

  styleEntries: ->
    width: '200px'

  styleKey: ->
    backgroundColor: Color().hsl(0,0,90,0.5).hslString()
    padding: '0 10px'
    lineHeight: '20px'
    fontSize: '14px'
    display: 'inline-block'
    borderRadius: '4px'
    cursor: 'pointer'
    marginRight: '10px'

  styleValue: ->
    flex: 1
    margin: 0
