models = NS "FLIPS.models"
utils = NS "FLIPS.utils"

log = console.log
console.log = (msg, others...) ->
  msg = "#{ window.location.href }: #{ msg }"
  others.unshift msg
  log.call this, msg


class models.SlideShowModel extends Backbone.Model

  urlRoot: "/slides"

  constructor: ->
    super

    if not @get "id"
      console.log "no id for model. setting default"
      @set html: utils.mock

    @bind "init", ->
      console.log "init"
    @bind "change", ->
      console.log "change"


  toJSON: ->
    html: @get "html"
    id: @get "id"
