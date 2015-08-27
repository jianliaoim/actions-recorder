
fs = require('fs')
webpack = require('webpack')

module.exports =
  entry:
    vendor: [
      'react'
      'immutable'
      'webpack-dev-server/client?http://repo:8080'
      'webpack/hot/dev-server'
    ]
    main: [ './src/main' ]
  output:
    path: 'build/'
    filename: '[name].js'
    publicPath: 'http://repo:8080/build/'
  resolve: extensions: ['.js', '.coffee', '' ]
  module: loaders: [
    {test: /\.coffee$/, loader: 'react-hot!coffee', ignore: /node_modules/}
    {test: /\.css$/, loader: 'style!css'}
  ]
  plugins: [ new (webpack.optimize.CommonsChunkPlugin)('vendor', 'vendor.js') ]
