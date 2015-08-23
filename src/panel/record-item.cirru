
var
  React $ require :react
  Immutable $ require :immutable

var
  div $ React.createFactory :div

= module.exports $ React.createClass $ {}
  :displayName :recorder-item

  :propTypes $ {}
    :index React.PropTypes.number.isRequired
    :record $ React.PropTypes.instanceOf Immutable.List

  :render $ \ ()
    div null (this.props.record.get 0)
