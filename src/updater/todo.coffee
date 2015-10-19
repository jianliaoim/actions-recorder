
exports.add = (store, actionData) ->
  store.push actionData

exports.update = (store, actionData) ->
  id = actionData.get("id")
  text = actionData.get("text")
  store.map (task) ->
    if task.get("id") is id
      task.set("text", text)
    else task

exports.toggle = (store, id) ->
  store.map (task) ->
    if task.get("id") is id
      task.update "done", (done) ->
        not done
    else task

exports.remove = (store, id) ->
  store.filterNot (task) ->
    task.get("id") is id
