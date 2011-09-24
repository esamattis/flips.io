# Module dependencies.

_  = require 'underscore'
_.mixin require 'underscore.string'


{alphabet} = require "./urlshortener"
{app, io} = require "./configure"
module.exports = app
db = require "./db"
urlgen = require "./shorturlgenerator"
jade = require 'jade'

popBackboneId = (ob) ->
  id = ob.id
  delete ob.id
  id



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
  console.log "ADD NEW", req.body
  urlgen.getNext (url) ->
    db.save url, req.body, (err, doc) ->
      if err
        console.log "error posting", req.body, err
        res.send 501
        res.end JSON.stringify err
        return
      console.log "ALL ok", arguments
      res.end JSON.stringify doc
      console.log "done"

app.put "/slides/:id", (req, res) ->
  res.contentType 'json'

  id = popBackboneId req.body

  db.get id, (err, doc) ->
    secret = doc.secret
    if secret and secret isnt req.cookies.secret
      console.log "CANNOT SAVE", id, secret, "!=", req.cookies.secret
      res.send 501
      res.end JSON.stringify
        error: 1
        message: "wrong secret"
      return

    db.save id, req.body, (err, doc) ->
      if err
        console.log "error updating", req.body, err
        res.send 501
        res.end JSON.stringify err
        return

      # Update cache for manage sockets
      secretCache[id] = secret

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

    secret = doc.secret
    if secret and req.cookies.secret isnt secret
      doc.readOnly = true
      delete doc.secret
      console.log "Read only!", doc._id

    res.end JSON.stringify doc


app.get new RegExp("^/([#{ alphabet }]+$)"), (req, res) ->
  res.exec ->
    $ ->
      window.slideShowView = new FLIPS.views.SlideShowView
        model: new FLIPS.models.SlideShowModel
          id: _.last window.location.pathname.split("/")

  res.render "slideshow"
    layout: false


app.get "/start/initial", (req, res) ->
  res.exec ->
    $ ->
      window.slideShowView = new FLIPS.views.SlideShowView
        model: new FLIPS.models.SlideShowModel

  res.render "slideshow"
    layout: false



app.get "/r/:id", (req, res) ->
  res.exec ->
    $ -> new FLIPS.views.MobileRemote
        model: new FLIPS.models.SlideShowModel
          id: _.last window.location.pathname.split("/")

  res.render "remote"
    layout: false

allowedCmds =
  goto: true
  reload: true
  update: true

secretCache = {}

routeManage = (ob) ->
    if not allowedCmds[ob.cmd]
      console.log "Illegal command #{ ob.cmd } for #{ ob.target }"
      return

    if secretCache[ob.target] is null or secretCache[ob.target] is ""
      console.log "no secret. routing"
      @broadcast.to(ob.target).emit "cmd", ob

    else if secretCache[ob.target] is undefined
      console.log "secret not in cache"

      db.get ob.target, (err, doc) =>
        if doc.secret
          secretCache[ob.target] = doc.secret
        else
          secretCache[ob.target] = null

        console.log "got secret from couch, recursing"
        routeManage.call @, ob

    else if secretCache[ob.target] is ob.secret
      console.log "secret ok. routing"
      @broadcast.to(ob.target).emit "cmd", ob

    else
      console.log "wrong secret #{ ob.secret } should be #{ secretCache[ob.target] }"
      @emit "unauthorized", "bad secret"


io.sockets.on 'connection', (socket) ->
  socket.on "cmd", routeManage
  socket.on "obey", (id) ->
    @join id

if require.main is module
  app.listen(8000)

  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env)

