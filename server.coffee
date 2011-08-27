# Module dependencies.

_  = require 'underscore'
_.mixin require 'underscore.string'

app = module.exports = require "./configure"
db = require "./db"

popBackboneId = (ob) ->
  id = ob.id
  delete ob.id
  id


# Routes

app.get '/', (req, res) ->
  res.exec ->
    $ ->
      ws = new FLIPS.Workspace
      Backbone.history.start()

  res.render 'index',
    title: 'Flips.io'

app.post "/slides", (req, res) ->
  res.contentType 'json'
  # console.log "POST", req.body

  db.save req.body, (err, doc) ->
    if err
      console.log "error posting", req.body, err
      res.send 501
      res.end JSON.stringify err
      return
    console.log "posted", doc
    res.end JSON.stringify doc

app.put "/slides/:id", (req, res) ->
  res.contentType 'json'


  id = popBackboneId req.body
  # console.log "PUT", req.body

  db.save id, req.body, (err, doc) ->
    if err
      console.log "error updating", req.body, err
      res.send 501
      res.end JSON.stringify err
      return

    res.end JSON.stringify doc


app.get "/slides", (req, res) ->
  res.contentType 'json'
  console.log "GET SLIDES", req.body, req.params
  res.end()

app.get "/slides/:id", (req, res) ->
  res.contentType 'json'
  # console.log "GET", req.params

  db.get req.params.id, (err, doc) ->
    if err
      console.log "error getting", req.params, err
      res.send 501
      res.end JSON.stringify err
      return

    console.log "got", doc
    res.end JSON.stringify doc


app.get "/view/:id", (req, res) ->
  res.exec ->
    $ ->
      window.slideShowView = new FLIPS.SlideShowView
        model: new FLIPS.models.SlideShow
          id: _.last window.location.pathname.split("/")


  res.render "slideshow"
    layout: false


if require.main is module
  app.listen(8000)
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env)

