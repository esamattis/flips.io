fs = require "fs"

urlshortener = require "./urlshortener"


filepath = __dirname + "/sequence.db"
current = null
last = null


persistCurrent = (cb) ->

  if current is last
    cb?()
    return

  fs.writeFile filepath, current.toString(), (err, data) ->
    throw err if err
    last = current
    console.log "saved #{ current }"
    cb? data

signalHandler = (e) ->
  persistCurrent ->
    console.log "exiting"
    process.exit()

process.on "SIGINT", signalHandler
process.on "SIGTERM", signalHandler

setTimeout ->

  fs.readFile filepath, (err, data) ->
    if err
      current = 1
      persistCurrent()
    else
      current = last = parseInt data.toString(), 10
      console.log "starting from", current

, 1000

setInterval persistCurrent, 1000

exports.getNext = (cb) ->
  throw new Error("seq is not read yet") if current is null
  cb urlshortener.encode ++current


if require.main is module
  setInterval ->
    console.log "getting #{ exports.getNext() }"
  , 500

