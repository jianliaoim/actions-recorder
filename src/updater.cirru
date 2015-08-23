
var
  todo $ require :./controller/todo

= module.exports $ \ (store actionType actionData)
  case actionType
    :todo/add
      todo.add store actionType actionData
    :todo/update store
      todo.update store actionType actionData
    :todo/toggle
      todo.toggle store actionType actionData
    :togo/remove store
      todo.remove store actionType actionData
    else
      console.warn $ + ":Unknown action type: " actionType
      , store
