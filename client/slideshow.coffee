
SlideShow = FLIPS.models.SlideShow


class FLIPS.SlideShowView extends Backbone.View
  el: '.deck-container'

  constructor: (opts) ->
    super opts

    @model.bind "change", =>
      $ =>
        alert('change')
        @render()
        $.deck(".slide")

    @model.fetch()

  render: ->
    $(@el).html @model.get "html"
    
    # 
    # 
    # 
    # class FLIPS.SlideShowRouter extends Backbone.Router
    # 
    #   routes:
    #     "": "start"
    #     "slide/:pos": "change"
    # 
    #   constructor: ->
    #     super
    # 
    #     @slideShowID =  _.last window.location.pathname.split("/")
    #     @showslide = new ShowSlide
    #       el: ".deck-container"
    #       model: new SlideShow
    #         id: @slideShowID
    # 
    # 
    # 
    #   start: ->
    #     console.log "start"
    # 
    #   change: (pos) ->
    #     console.log "change slide to ", pos
    
