
React = require 'react'
Immutable = require 'immutable'

{div} = React.DOM

module.exports = React.createClass
  displayName: 'recorder-viewer'

  propTypes:
    data: React.PropTypes.instanceOf(Immutable.Collection).isRequired

  render: ->
    div null, 'data'
