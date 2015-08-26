
var
  React $ require :react
  Immutable $ require :immutable
  classnames $ require :classnames

var
  div $ React.createFactory :div
  pre $ React.createFactory :pre

= module.exports $ React.createClass $ {}
  :displayName :recorder-item

  :propTypes $ {}
    :index React.PropTypes.number.isRequired
    :record $ React.PropTypes.instanceOf Immutable.List
    :isPointer React.PropTypes.bool.isRequired
    :onPeek React.PropTypes.func.isRequired

  :onClick $ \ ()
    this.props.onPeek this.props.index

  :render $ \ ()
    var actionType $ this.props.record.get 0
    var actionData $ this.props.record.get 1
    var className $ classnames :recorder-item $ {}
      :is-pointer this.props.isPointer

    div ({} (:className className) (:onClick this.onClick))
      div ({} (:className :record-title)) actionType
      pre ({} (:className :record-content))
        JSON.stringify actionData null 2
