
SlideShow = FLIPS.models.SlideShow


class FLIPS.SlideShowView extends Backbone.View
  el: '.deck-container'

  constructor: (opts) ->
    super opts

    @model.bind "change", =>
      $ =>
        @render()
        $.deck(".slide")

    @model.fetch()

  render: ->
    $(@el).prepend @model.get "html"