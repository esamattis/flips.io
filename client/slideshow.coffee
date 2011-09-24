
views = NS "FLIPS.views"
utils = NS "FLIPS.utils"
remote = NS "FLIPS.remote"
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

    # jade = require('jade')
    # template = jade.compile $("#deck_template").html()
    # @deckHTML = template()

    @deckHTML = $("#deck_template").html()

    @receiver = new remote.Receiver this

    @currentSlideId = 0
    $(document).bind "deck.change", (event, from, to) =>
      console.log "SLIDE CHANGE", event, from, to
      @currentSlideId = to

    if not @model.get "id"
      @model.set code: utils.mock, mode: 'html'
      @render()


    @model.bind "change", =>
      @render()

    @model.fetch()



  update: (data) ->
    console.log "updating model with", data
    utils.msg.info "Model updated"
    @model.set data

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
    $(@el).html @deckHTML
    $(@el).prepend @model.getHtml()
    $.deck(".slide")


