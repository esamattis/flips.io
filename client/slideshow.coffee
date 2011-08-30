
views = NS "FLIPS.views"
utils = NS "FLIPS.utils"
{SlideShow} = FLIPS.models


class views.SlideShowView extends Backbone.View
  el: '.deck-container'

  constructor: (opts) ->
    super
    @deckNavigationHTML = $("#deck_template").html()

    $(window).bind "message", (e) =>
      data = e.originalEvent.data
      console.log "Iframe got a message from parent", data
      @model.set code: data

    @socket = utils.getSocket()

    if not @model.get "id"
      @model.set code: utils.mock, mode: 'html'
      @render()

    @socket.on "connect", =>
      console.log "connected"
      if @model.get "id"
        @_connectToRemote()
      else
        @model.bind "change", _.once =>
          @_connectToRemote()

    @socket.on "command", (ob) =>
      console.log "got cmd", ob.args
      ob.args ?= []
      @[ob.name]?.apply this, ob.args

    @model.bind "change", =>
      @render()

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
    $(@el).html @deckNavigationHTML
    $(@el).prepend @model.getHtml()
    $.deck(".slide")

