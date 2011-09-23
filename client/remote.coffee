utils = NS "FLIPS.utils"
remote = NS "FLIPS.remote"


class Remote

  constructor: ->
    _.extend @, Backbone.Events

  update: (data) ->
    @post "update", data

  goto: (index) ->
    @post "update", index

  reload: ->
    @post "reload"


class remote.RemoteIframe extends Remote

  constructor: (@iframe) ->
    super

  post: (cmd, args...) ->
    w = @iframe.get(0).contentWindow
    console.log "posting to iframe", @iframe, w
    w.postMessage JSON.stringify(
      cmd: cmd
      args: args)
    , "*"


class remote.RemoteSocket extends Remote

  constructor: (@model, @secret) ->
    super
    @socket = utils.getSocket()

  post: (cmd, args...) ->
    @socket.emit "cmd",
      target: @mode.get "id"
      secret: @secret
      cmd: cmd
      args: args


class remote.Receiver

  constructor: (@ob) ->
    _.extend @, Backbone.Events
    @bind "cmd", (cmdOb) ->
      @ob[cmdOb.cmd]?.apply @ob, cmdOb.args
    @listenParentWindow()
    @listenSocket()

  listenParentWindow: ->
    console.log "listening window"
    $(window).bind "message", (e) =>
      console.log "getting from parent window", e
      cmdOb = JSON.parse e.originalEvent.data
      @trigger "cmd", cmdOb

  listenSocket: ->
    @socket = utils.getSocket()
    @socket.on "connect", =>

      if @ob.model.get "id"
        @_obey()
      else
        @ob.model.bind "change:id", _.once =>
          @_obey()

    @socket.on "cmd", (cmdOb) =>
      @trigger "cmd", cmdOb

    @socket.on "unauthorized", (msg) ->
      alert msg

  _obey: ->
      console.log "connecting to socket remote"
      @socket.emit "obey", @ob.model.get "id"



