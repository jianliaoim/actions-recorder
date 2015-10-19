
todo = require("./todo")

module.exports = (store, actionType, actionData) ->
  switch actionType
    when "todo/add"
      todo.add store, actionData
    when "todo/update"
      todo.update store, actionData
    when "todo/toggle"
      todo.toggle store, actionData
    when "todo/remove"
      store
      todo.remove store, actionData
    else
      console.warn "Unknown action type: " + actionType
      store
