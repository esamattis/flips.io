
db = require "../lib/db"

exports.resetDB = (jasmine) -> ->
  if not process.env.FLIPS_DB or process.env.FLIPS_DB is "flips"
    throw "Running tests with production db!"

  jasmine.asyncSpecWait()
  console.log "destroying exinsting db".toUpperCase()
  db.destroy ->
    console.log "destroyed", arguments
    db.create ->
      console.log "created new ", arguments
      jasmine.asyncSpecDone()

