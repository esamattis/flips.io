
views = NS "FLIPS.views"
utils = NS "FLIPS.utils"
SlideShow = FLIPS.models.SlideShow


# next slide
# prev
# goto
# reload

class views.SlideShowView extends Backbone.View
  el: '.deck-container'

  constructor: (opts) ->
    super
    @socket = utils.getSocket()
    @socket.on "connect", =>
      console.log "connected"
      if @model.get "id"
        @_connectToRemote()
      else
        @model.bind "change", _.once =>
          @_connectToRemote()

    @socket.on "command", (cmd) =>
      console.log "got cmd", cmd
      @[cmd]?()

    @model.bind "change", =>
      $ =>

        @render()
        $.deck(".slide")

    @model.fetch()

  _connectToRemote: ->
      console.log "connecting to remote"
      @socket.emit "obey", @model.get "id"

  next: ->
    $.deck("next")

  prev: ->
    $.deck("prev")

  reload: ->
    window.location.reload()

  # Indexing starts from 0.
  goto: (slide) ->
    $.deck("go", slide)

  render: ->
    $(@el).prepend @model.get "html"
