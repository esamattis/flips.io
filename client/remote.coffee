views = NS "FLIPS.views"
utils = NS "FLIPS.utils"

class views.Remote extends Backbone.View

  constructor: ->
    super
    @id = _.last window.location.pathname.split("/")
    @socket = utils.getSocket()
    @socket.on "connect", =>
      console.log "connected"
      $("#next").click (e) =>
        @socket.emit "manage",
          target: @id
          command: "next"

      $("#prev").click (e) =>
        @socket.emit "manage",
          target: @id
          command: "prev"









