
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
    :records (Immutable.List)
    :pointer -1
  , document.body

recorder.subscribe $ \ (store records pointer)
  React.render
    Page $ {} (:store store) (:records records) (:pointer pointer)
    , document.body
