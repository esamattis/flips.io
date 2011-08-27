
SlideShow = FLIPS.models.SlideShow

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
  
  reload: ->
    window.location.reload()  
  
  # Indexing starts from 0.
  goto: (slide) ->
    $.deck("go", slide)

  render: ->
    $(@el).prepend @model.get "html"
