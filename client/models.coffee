models = NS "FLIPS.models"
utils = NS "FLIPS.utils"

class models.SlideShowModel extends Backbone.Model

  urlRoot: "/slides"

  constructor: ->
    super
    @triggerInitialFetch = _.once (source) =>
      @trigger "initialfetch",
        source: source
        target: @

  getPresentationURL: ->
    "/#{@get "id"}"

  getRemoteURL: ->
    "/r/#{@get "id"}"

  getEditURL: ->
    "/#edit/#{@get "id"}"

  toJSON: ->
    secret: @get "secret"
    html: @get "html"
    id: @get "id"

  fetch: (opts={}) ->
    origCb = opts.success
    opts.success = (e) =>
      @triggerInitialFetch "db"
      origCb? e

    if not @get "id"
      console.log "using mock"
      @set html: utils.mock
      @triggerInitialFetch "default"
      origCb? e
      opts.success @
    else
      console.log "really fecthing"
      super opts
