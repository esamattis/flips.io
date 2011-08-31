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

  parsers:
    html: (html) -> html
    jade: (code) ->
      jade = require('jade')
      try
        jade.compile(code)()
      catch e
        """
        <div class="slide jade_error">
          <h2>Invalid Jade syntax</h2>
          <pre>#{ $('<div>').text(e.message).html() }</pre>
          <a href="http://jade-lang.com/" target="_blank">What is Jade?</a>
        </div>
        """

  getHtml: ->
    parser = @parsers[@get "mode"]
    parser = @parsers.html unless parser
    parser @get "code"


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
    theme: @get "theme"
    id: @get "id"

  fetch: (opts={}) ->
    origCb = opts.success
    opts.success = (e) =>
      @triggerInitialFetch "db"
      origCb? e

    if not @get "id"
      console.log "using mock"
      @set code: utils.mock, mode: 'html', transition: 'nothing', theme: 'nothing', currentSlide: '0'
      @triggerInitialFetch "default"
      origCb? e
      opts.success @
    else
      console.log "really fecthing"
      super opts
