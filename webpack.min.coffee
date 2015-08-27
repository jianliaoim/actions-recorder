
webpack = require('webpack')
config = require('./webpack.config')
fs = require('fs')

module.exports =
  entry:
    main: [ './src/main' ]
    vendor: ['react', 'immutable']
  output:
    path: 'build/'
    filename: '[name].[chunkhash:8].js'
    publicPath: './build/'
  resolve: config.resolve
  module: config.module
  plugins: [
    new (webpack.optimize.CommonsChunkPlugin)('vendor', 'vendor.[chunkhash:8].js')
    new (webpack.optimize.UglifyJsPlugin)(sourceMap: false)
    ->
      @plugin 'done', (stats) ->
        json = stats.toJson()
        content = JSON.stringify(json.assetsByChunkName, null, 2)
        fs.writeFileSync 'build/assets.json', content
  ]
