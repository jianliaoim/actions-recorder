ua = navigator.userAgent.toLowerCase()

if ua.indexOf('safari') isnt -1
  if ua.indexOf('chrome') > -1
    module.exports = false
  else
    module.exports = true
else
  module.exports = false
