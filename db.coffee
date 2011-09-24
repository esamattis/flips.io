
cradle = require('cradle')
_  = require 'underscore'
_.mixin require 'underscore.string'

c = new cradle.Connection


dbname = process.env.FLIPS_DB or "flips"
db = c.database dbname


db.getAlways = (id, initdoc, cb) ->
  db.get id, (err, doc) ->
    if err?.reason is "missing"
      db.save id, initdoc, (err, res) ->
        return cb? err if err
        db.getAlways id, initdoc, cb
    else if err
      cb? err
    else 
      cb? null, doc





init = ->
  console.log "Connected to CouchDB", dbname

module.exports = db



if require.main is module
  db.getAlways "jea", hoh: 1, (err, doc) ->
    throw err if err
    console.log "got", doc

