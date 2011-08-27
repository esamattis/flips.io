NS "FLIPS.models"

FLIPS.models.SlideShow = class SlideShow extends Backbone.Model

  urlRoot: "/slides"


  toJSON: ->
    html: @get "html"
    id: @get "id"
