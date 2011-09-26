fs = require "fs"

{encode} = require "./urlshortener"
db = require "./db"


reservedNames =
  admin: 1
  slide: 1
  slides: 1
  index: 1
  id: 1
  r: 1
  edit: 1
  view: 1
  start: 1
  presentation: 1
  remote: 1
  mobile: 1
  mob: 1
  m: 1





exports.nextUrl = (cb) ->
  db.db.getAlways "urlsequence", sequence: 0, (err, doc) ->
    return cb err if err

    loop # Skip reserved names
      seq = doc.sequence += 1
      url = encode seq
      break unless reservedNames[url]


    db.db.save "urlsequence", doc, (err) ->
      if err?.error is "conflict"
        console.log "#{ seq } #{ url } is in conflict. Retrying."
        return exports.nextUrl cb

      return cb err if err


      db.db.get url, (err, doc) ->

        if err?.error is "not_found"
          return cb null, url

        return cb err if err

        exports.nextUrl cb





