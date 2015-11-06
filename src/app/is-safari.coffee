
detectIsSafari = ->
  return false if (typeof window) is 'undefined'
  ua = window.navigator.userAgent.toLowerCase()
  return false if ua.indexOf('safari') is -1 # webkit
  return false if ua.indexOf('chrome') isnt -1 # chrome
  return true

module.exports = detectIsSafari()
