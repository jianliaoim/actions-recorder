
var
  fs $ require :fs
  webpack $ require :webpack

= module.exports $ object
  :entry $ object
    :vendor $ array :react :immutable
      , :webpack-dev-server/client?http://repo:8080
      , :webpack/hot/dev-server
    :main $ array :./src/main

  :output $ object
    :path :build/
    :filename :[name].js
    :publicPath :http://repo:8080/build/

  :resolve $ object
    :extensions $ array :.js :.cirru :

  :module $ object
    :loaders $ array
      object (:test /\.cirru$) (:loader :react-hot!cirru-script) (:ignore /node_modules)
      object (:test /\.css$) (:loader :style!css)

  :plugins $ array
    new webpack.optimize.CommonsChunkPlugin :vendor :vendor.js
