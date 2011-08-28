views = NS "FLIPS.views"
utils = NS "FLIPS.utils"

class views.Remote extends Backbone.View
  el: ".remote"

  constructor: ->
    super
    @current = 0
    @currentEl = @$ "#current"
    @maxEl = @$ "#max"

    @model.bind "initialfetch", =>
      slideHTML = @model.get "html"
      slideCount = $("<div>").html(slideHTML).find(".slide").size()
      @max = slideCount
      @render()
      @connectToSocketIo()

    @model.fetch()
    @socket = utils.getSocket()


  connectToSocketIo: ->
    @socket.on "connect", =>
      utils.msg.info "Connected to server"

      $("#next").click (e) =>
        if @current is @max-1
          utils.msg.error "Last slide"
          return

        @socket.emit "manage",
          target: @model.get "id"
          name: "goto"
          args: [++@current]
        @render()

      $("#prev").click (e) =>
        if @current is 0
          utils.msg.error "First slide"
          return
        @socket.emit "manage",
          target: @model.get "id"
          name: "goto"
          args: [--@current]
        @render()


  render: ->
    @currentEl.text @current
    @maxEl.text @max
    console.log "setting #{ @current }"
    @currentEl.text @current+1






