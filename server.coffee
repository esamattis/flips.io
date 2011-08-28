# Module dependencies.

_  = require 'underscore'
_.mixin require 'underscore.string'

{app, io} = require "./configure"
module.exports = app
db = require "./db"
urlgen = require "./shorturlgenerator"


popBackboneId = (ob) ->
  id = ob.id
  delete ob.id
  id

urlId = 1


# Routes
# http://localhost:5984/flips/_design/slides/_view/urlIds?key=3
app.get "/urls/:url", (req, res) ->
  res.contentType 'json'
  console.log "sdf", req.params.url
  db.getDocByURL req.params.url, (err, doc) ->
    res.end JSON.stringify doc

app.get '/', (req, res) ->
  res.exec ->
    $ ->
      ws = new FLIPS.Workspace
      Backbone.history.start()

  res.render 'index',
    title: 'Flips.io'

app.post "/slides", (req, res) ->
  res.contentType 'json'
  urlgen.getNext (url) ->
    req.body.url = url

    db.save req.body, (err, doc) ->
      if err
        console.log "error posting", req.body, err
        res.send 501
        res.end JSON.stringify err
        return
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

    res.end JSON.stringify doc


app.get "/view/:id", (req, res) ->
  res.exec ->
    $ ->
      window.slideShowView = new FLIPS.views.SlideShowView
        model: new FLIPS.models.SlideShowModel
          id: _.last window.location.pathname.split("/")

  res.render "slideshow"
    layout: false


app.get "/initial", (req, res) ->
  res.exec ->
    $ ->
      window.slideShowView = new FLIPS.views.SlideShowView
        model: new FLIPS.models.SlideShowModel

  res.render "slideshow"
    layout: false



app.get "/r/:id", (req, res) ->
  res.exec ->
    $ -> new FLIPS.views.Remote
        model: new FLIPS.models.SlideShowModel
          id: _.last window.location.pathname.split("/")

  res.render "remote"
    layout: false

allowedCmds =
  goto: true
  reload: true

io.sockets.on 'connection', (socket) ->

  socket.on "manage", (ob) ->

    if not allowedCmds[ob.name]
      console.log "Illegal command #{ ob.name } for #{ ob.target }"
      return

    @broadcast.to(ob.target).emit "command", ob

  socket.on "obey", (id) ->
    @join id



if require.main is module
  app.listen(8000)
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env)

