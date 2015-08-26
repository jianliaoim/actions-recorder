
var
  React $ require :react
  Immutable $ require :immutable

var
  actions $ require :../actions

var
  Todolist $ React.createFactory $ require :./todolist
  Controller $ React.createFactory $ require :../panel/controller

var
  div $ React.createFactory :div

= module.exports $ React.createClass $ {}
  :displayName :app-page

  :propTypes $ {}
    :store $ React.PropTypes.instanceOf Immutable.List
    :recorder React.PropTypes.object.isRequired

  :onCommit $ \ ()
    actions.internalCommit

  :onSwitch $ \ ()
    actions.internalSwitch

  :onReset $ \ ()
    actions.internalReset

  :onPeek $ \ (position)
    actions.internalPeek position

  :onDiscard $ \ ()
    actions.internalDiscard

  :render $ \ ()
    div ({} (:className :app-page))
      Todolist $ {}
        :store this.props.store
      Controller $ {}
        :records this.props.recorder.records
        :pointer this.props.recorder.pointer
        :isTravelling this.props.recorder.isTravelling
        :onCommit this.onCommit
        :onSwitch this.onSwitch
        :onReset this.onReset
        :onPeek this.onPeek
        :onDiscard this.onDiscard
