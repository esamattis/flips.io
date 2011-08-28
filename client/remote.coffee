views = NS "FLIPS.views"
utils = NS "FLIPS.utils"

class views.Remote extends Backbone.View
  el: ".remote"

  constructor: ->
    super
    @currentEl = @$ "#current"
    @id = _.last window.location.pathname.split("/")
    @socket = utils.getSocket()
    @current = 0

    @socket.on "connect", =>
      console.log "connected"

      $("#next").click (e) =>
        console.log "nexting"
        @socket.emit "manage",
          target: @id
          name: "goto"
          args: [++@current]
        @render()

      $("#prev").click (e) =>
        console.log "preving"
        @socket.emit "manage",
          target: @id
          name: "goto"
          args: [--@current]
        @render()


  render: ->
    @currentEl.text @current






