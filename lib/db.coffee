
cradle = require('cradle')
_  = require 'underscore'
_.mixin require 'underscore.string'

dbname = process.env.FLIPS_DB or "flips"

exports.connect = ->

  exports.connection = c = new cradle.Connection
  db = exports.db = c.database dbname

  db.getAlways = (id, initdoc, cb) ->
    db.get id, (err, doc) ->
      if err?.reason is "missing"
        db.save id, initdoc, (err, res) ->

          # Somebody else got before us. Just retry and get what he got.
          if err?.error is "conflict"
            return db.getAlways id, initdoc, cb

          return cb? err if err
          db.getAlways id, initdoc, cb
      else if err
        cb? err
      else 
        cb? null, doc


  console.log "Connecting to", dbname


exports.connect()


