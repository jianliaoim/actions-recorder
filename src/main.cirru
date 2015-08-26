
var
  React $ require :react
  Immutable $ require :immutable

var
  recorder $ require :./core/recorder
  updater $ require :./updater
  initial $ require :./initial

require :origami-ui
require :../style/main.css

recorder.setup initial updater

var
  Page $ React.createFactory $ require :./app/page

React.render
  Page $ {} (:store initial)
    :recorder $ {}
      :records (Immutable.List)
      :pointer 0
      :isTravelling false
  , document.body

recorder.subscribe $ \ (store recorder)
  React.render
    Page $ {} (:store store) (:recorder recorder)
    , document.body
