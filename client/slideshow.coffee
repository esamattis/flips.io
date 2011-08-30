
views = NS "FLIPS.views"
utils = NS "FLIPS.utils"
{SlideShow} = FLIPS.models


class CSSSwitcher extends Backbone.View
  tagName: "link"
  modelAttr: null

  getHref: -> throw new Error "Abstract class"

  constructor: (opts) ->
    super
    @head = $("head").get 0
    $(@el).attr "rel", "stylesheet"
    @model.bind "change:#{ @modelAttr }", => @render()

  isInDOM: -> $.contains @head, @el
  getValue: -> @model.get @modelAttr 

  render: ->
    value = @model.get @modelAttr
    if not value or value is "nothing"
      $(@el).detach()
      return

    $(@el).attr "href", @getHref()

    if not @isInDOM()
      console.log "adding css"
      $(@head).append @el

class TransitionSwitcher extends CSSSwitcher
  modelAttr: "transition"
  getHref: ->
     "/deck.js/themes/transition/#{ @getValue() }.css"

class ThemeSwicher extends CSSSwitcher
  modelAttr: "theme"
  getHref: ->
     "/deck.js/themes/style/#{ @getValue() }.css"


class views.SlideShowView extends Backbone.View
  el: '.deck-container'

  constructor: (opts) ->
    super
    @transitionSwitcher = new TransitionSwitcher
      model: @model
    @themeSwitcher = new ThemeSwicher
      model: @model

    @deckNavigationHTML = $("#deck_template").html()

    $(window).bind "message", (e) =>
      console.log "MSEG", $.deck('getSlide')
      data = e.originalEvent.data
      @model.set JSON.parse data

    @currentSlideId = 0
    $(document).bind "deck.change", (event, from, to) =>
      console.log "SKIDE CHGAN", event, from, to
      @currentSlideId = to


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

