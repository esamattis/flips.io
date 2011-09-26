
db = require "../lib/db"
request = require('request')

exports.resetDB = (jasmine, cb) ->
  if not process.env.FLIPS_DB or process.env.FLIPS_DB is "flips"
    throw "Running tests with production db!"
  name = process.env.FLIPS_DB
  request
    method: "DELETE"
    url: "http://127.0.0.1:5984/#{ name }"
  , ->
    request
      method: "PUT"
      url: "http://127.0.0.1:5984/#{ name }"
    ,  ->
      db.connect()
      cb null
