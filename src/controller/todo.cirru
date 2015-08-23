
= exports.add $ \ (store actionType actionData)
  store.push actionData

= exports.update $ \ (store actionType actionData)
  var id $ actionData.get :id
  var text $ actionData.get :text
  store.map $ \ (task)
    cond (is (task.get :id) id)
      task.set :text text
      , task

= exports.toggle $ \ (store actionType actionData) store
  var id actionData
  store.map $ \ (task)
    cond (is (task.get :id) id)
      task.update :done $ \ (done) (not done)
      , task

= exports.remove $ \ (store actionType actionData) store
  var id actionData
  store.filterNot $ \ (task)
    is (task.get :id) id
