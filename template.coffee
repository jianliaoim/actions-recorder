
stir = require('stir-template')

html = stir.html
head = stir.head
title = stir.title
meta = stir.meta
link = stir.link
script = stir.script
body = stir.body
div = stir.div

module.exports = (data) ->
  stir.render stir.doctype(),
    html null,
      head null,
        title null, 'Actions Recorder'
        meta charset: 'utf-8'
        link rel: 'icon', href: 'http://mvc-works.org/png/mvc.png'
        script src: data.vendor, defer: true
        script src: data.main, defer: true
      body null
