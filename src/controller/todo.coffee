
exports.add = (store, actionType, actionData) ->
  store.push actionData

exports.update = (store, actionType, actionData) ->
  id = actionData.get("id")
  text = actionData.get("text")
  store.map (task) ->
    (if task.get("id") is id then task.set("text", text) else task)


exports.toggle = (store, actionType, actionData) ->
  store
  id = actionData
  store.map (task) ->
    if task.get("id") is id
      task.update "done", (done) ->
        not done
    else
      task

exports.remove = (store, actionType, actionData) ->
  id = actionData
  store.filterNot (task) ->
    task.get("id") is id
