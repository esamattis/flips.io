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

  getHtml: ->
    mode = @get "mode"
    code = @get "code"
    if mode == "html"
      return code
    else if mode == "jade"
      jade = require('jade')
      return jade.compile(code)()
    else
      return '<script type="text/javascript">alert("should not happen");</script>'

  getPresentationURL: ->
    "/#{@get "id"}"

  getRemoteURL: ->
    "/r/#{@get "id"}"

  getEditURL: ->
    "/#edit/#{@get "id"}"

  toJSON: ->
    secret: @get "secret"
    code: @get "code"
    mode: @get "mode"
    transition: @get "transition"
    language: @get "language"
    id: @get "id"

  fetch: (opts={}) ->
    origCb = opts.success
    opts.success = (e) =>
      @triggerInitialFetch "db"
      origCb? e

    if not @get "id"
      console.log "using mock"
      @set code: utils.mock, mode: 'html'
      @triggerInitialFetch "default"
      origCb? e
      opts.success @
    else
      console.log "really fecthing"
      super opts
