
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

db.save '_design/slides',
  url:
    map: (doc) ->
      if doc.url
        emit doc.url, doc

db.getDocByURL = (url, cb) ->
  db.view "slides/url", key: url,  (err, docs) ->
    console.log "GETC", err, docs
    doc = if _.isEmpty(docs) then null else _.first(docs).value
    cb err, doc

init = ->
  console.log "Connected to CouchDB"

module.exports = db


if require.main is module
  db.getAlways "jea", hoh: 1, (err, doc) ->
    throw err if err
    console.log "got", doc

