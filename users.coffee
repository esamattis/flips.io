cradle = require('cradle')

c = new cradle.Connection
name = "flips_users"
db = c.database name

db.save '_design/users',
  githubId:
    map: (doc) ->
      if doc.githubId
        emit doc.githubId, doc

exports.findOrCreateUserGithub = (githubData, promise) =>
  db.view('users/githubId', {key: githubData.id}, (err, doc) =>
    if err
      console.log 'error!'
      console.log githubData.id
      console.log err
      promise.fail(err)
      return;
      
    if doc && doc.length > 0
      console.log 'doc exists'
      console.log doc.length
      promise.fulfill(doc)
    else
      doc =
        name: githubData.name,
        githubId: githubData.id
        
      db.save(doc, (err, res) -> 
        if err
          console.log "error saving to users database"
          console.log err
          promise.fail(err)
          return;
        
        console.log 'succesfully created new user'
        promise.fulfill(doc)
      )
  )
  
exports.findUser = (userId) =>
  console.log "HERE WE ARE"
  console.log userId
  debugger