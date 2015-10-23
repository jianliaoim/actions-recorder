
React = require("react")
Immutable = require("immutable")

Todolist = React.createFactory(require("./todolist"))
Devtools = React.createFactory(require("../devtools"))

div = React.createFactory("div")

module.exports = React.createClass
  displayName: "app-page"
  propTypes:
    core: React.PropTypes.instanceOf(Immutable.Map).isRequired

  render: ->
    div className: "app-page",
      Todolist(store: @props.core.get('cachedStore'))
      Devtools
        core: @props.core
        language: 'en'
        width: window.innerWidth
        height: window.innerHeight
