
cradle = require('cradle')
_  = require 'underscore'
_.mixin require 'underscore.string'

c = new cradle.Connection
name = "flips"
db = c.database name

db.exists (err, exists)->
  throw err if err
  if not exists
    db.create (err, foo) ->
      throw err if err
      console.log "created db", name
      init()
  else
    init()

db.getAlways = (id, initdoc, cb) ->
  db.get id, (err, doc) ->
    if err?.reason is "missing"
      console.log "saving", initdoc
      db.save id, initdoc, (err, res) ->
        return cb? err if err
        db.getAlways id, cb
    else if err
      cb? err
    else 
      cb? null, doc


init = ->
  console.log "Connected to CouchDB"

module.exports = db



if require.main is module
  db.getAlways "jea", hoh: 1, (err, doc) ->
    throw err if err
    console.log "got", doc

