
SlideShow = FLIPS.models.SlideShow
# next slide
# prev
# goto
# reload

class FLIPS.SlideShowView extends Backbone.View
  el: '.deck-container'

  constructor: (opts) ->
    super

    @model.bind "change", =>
      $ =>
        @render()
        $.deck(".slide")

    @model.fetch()
    
  next: ->
    $.deck("next")
    
  prev: ->
    $.deck("prev")
    
  # Indexing starts from 0.
  goto: (slide) ->
    $.deck("go", slide)

  render: ->
    $(@el).prepend @model.get "html"
