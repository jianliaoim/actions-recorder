
todo = require("./todo")

module.exports = (store, actionType, actionData) ->
  switch actionType
    when "todo/add"
      todo.add store, actionType, actionData
    when "todo/update"
      store
      todo.update store, actionType, actionData
    when "todo/toggle"
      todo.toggle store, actionType, actionData
    when "todo/remove"
      store
      todo.remove store, actionType, actionData
    else
      console.warn "Unknown action type: " + actionType
      store
