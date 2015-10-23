
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
    core = @props.core

    div className: "app-page",
      Todolist(store: core.get('cachedStore'))
      Devtools
        store: core.get('cachedStore')
        records: core.get('records')
        pointer: core.get('pointer')
        initial: core.get('initial')
        updater: core.get('updater')
        cachedStore: core.get('cachedStore')
        isTravelling: core.get('isTravelling')
        language: 'en'
        width: window.innerWidth
        height: window.innerHeight
