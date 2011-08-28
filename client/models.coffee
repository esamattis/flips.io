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


  toJSON: ->
    html: @get "html"
    id: @get "id"

  fetch: (opts={}) ->
    origCb = opts.success
    opts.success = (e) =>
      @triggerInitialFetch "db"
      origCb? e

    if not @get "id"
      @set html: utils.mock
      @triggerInitialFetch "default"
      origCb? e
      opts.success @
    else
      super opts
