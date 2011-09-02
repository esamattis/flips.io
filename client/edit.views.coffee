views = NS "FLIPS.edit.views"
utils = NS "FLIPS.utils"


class views.Editor extends Backbone.View
  el: ".edit_view"

  constructor: (opts) ->
    super

    HtmlMode = require('ace/mode/html').Mode
    JadeMode = require('ace/mode/jade').Mode

    @modes =
      html: new HtmlMode()
      jade: new JadeMode()

    @secret = new views.Secret

    @saveButton = $ "#save"

    @saveButton.click => @save()

    @initAce()

    @transitionEl = @$('#transition')
    @transitionEl.change =>
      @model.set transition: @transitionEl.val()

    @modeEl = @$('#mode')
    @modeEl.change =>
      @model.set mode: @modeEl.val()

    @themeEl = @$('#theme')
    @themeEl.change =>
      @model.set theme: @themeEl.val()

    # $(@el).find('textarea').listenInput =>
    @editor.getSession().selection.on 'changeCursor', =>
      selection = @editor.getSelectionRange()

      # Get code before selection
      range = selection.clone()
      range.setStart(0, 0)
      code = @editor.getSession().getTextRange(range)

      mode = @model.get "mode"
      result = 0
      # todo: improve the regexes
      if mode == "html"
        result = code.match(/<div class="slide">/g)
      else if mode == "jade"
        result = code.match(/\.slide/g)
      else
        alert('a fuzzy and cute kitten just died :(')

      newSlide = 0
      if result?
        newSlide = result.length - 1

      if newSlide != @currentSlide
        @currentSlide = newSlide
        console.log "slide changed!"

        data = {}#@model.toJSON()
        data["event"] = "onSlideChange"
        data["slide"] = @currentSlide
        $("iframe").get(0).contentWindow.postMessage JSON.stringify(data), "*"

    @model.bind "initialfetch", (e) =>
      @setEditorContents @model.get "code"
      @modeEl.val(@model.get "mode")
      @secret.setSecret @model.get "secret"
      @themeEl.val(@model.get "theme")
      @transitionEl.val(@model.get "transition")

      if e.source is "default"
        @showUnsavedNotification()
      else
        @hideUnsavedNotification()


    @model.bind "change", => @showUnsavedNotification()


  setEditorContents: (code) ->
    @editor.getSession().setValue code

  initAce: =>
    @editor = ace.edit "editor"
    @editor.setShowPrintMargin false

    session = @editor.getSession()
    session.setTabSize(2);

    @editor.getSession().on "change", =>
      @model.set code: @editor.getSession().getValue()

    @model.bind "change:mode", =>
      @editor.getSession().setMode(@modes[@model.get "mode"])

    # Hide the line numbering. TODO: doesn't work perfectly
    lineNumberWidth = parseInt($(".ace_scroller").css('left'))
    $(".ace_scroller").css('left', '0px')
    $(".ace_gutter").hide()
    $(".ace_scroller").css('width', parseInt($(".ace_scroller").css('width')) + lineNumberWidth)

    # Add save shortcut
    canon = require('pilot/canon')
    canon.addCommand
      name: 'saveCommand'
      bindKey:
        win: "Ctrl-S"
        mac: "Command-S"
        sender: 'editor'
      exec: (env, args, request) =>
        @save()

  getDocId: ->
    @model.get "id"

  showUnsavedNotification: ->
    @saveButton.text "Save*"
  hideUnsavedNotification: ->
    @saveButton.text "Save"

  save: ->
    console.log "sending save #{ document.cookie }"
    @model.save null,
      success: (e) =>
        @model.trigger "saved", @model
        # $.cookies.set "secret", @model.get "secret"
        document.cookie = "secret=#{  @model.get "secret" }"
        @hideUnsavedNotification()

        if not @hasEditUrl()
          window.location.hash = "#edit/#{ @model.get("id") }"

      error: (e, err) =>
        console.log "failed to save", @model, e, err
        utils.msg.error "failed to save #{ @model.get "id" }", true

  hasEditUrl: -> !!window.location.hash



class views.Preview extends Backbone.View

  constructor: (opts) ->
    super
    @socket = utils.getSocket()
    @iframe = @$("iframe")
    @contentWindow = @iframe.get(0).contentWindow
    @dirty = false

    @model.bind "change:id", => @reload()
    @model.bind "change", => @dirty = true
    $(window).keyup _.throttle =>
      return unless @dirty
      @dirty = false
      data = @model.toJSON()
      data["event"] = "onCodeChange"
      @contentWindow.postMessage JSON.stringify(@model.toJSON()), "*"
    , 400

    @model.bind "change:currentSlide", =>
      console.log "current slide changed to #{@model.get "currentSlide"}"

    @model.bind "saved", =>
      @setSecret @model.get "secret"
      @reload()
    @model.bind "initialfetch", (e) =>
      if e.source is "db"
        @reload()

  setSecret: (secret) ->
    @secret = secret

  reload: ->
    console.log "RELOADING PREVIEW", @model.id
    if @iframe.attr("src") is "/start/initial"
      @iframe.attr "src", @model.getPresentationURL()
      console.log "setting iframe to real url #{ @iframe.attr "src" }"
    else
      console.log "reloading iframe via socket"
      @socket.emit "manage",
        target: @model.get "id"
        name: "reload"
        secret: docCookies.getItem("secret")



# Refactor to listen to model's init and change events?
class views.Links extends Backbone.View
  el: '.toolbar'

  constructor: (opts) ->
    super
    @publicLink = @$('.public_link a')
    @remoteLink = @$('.remote_link a')

    @model.bind "change:id", => @render()
    @model.bind "initialfetch", => @render()

  render: ->
    if @model.get "id"
      @publicLink.attr('href',@model.getPresentationURL()).show "slow"
      @remoteLink.attr('href', @model.getRemoteURL()).show "slow"


class views.AskSecret extends Backbone.View
  el: ".ask_secret"

  constructor: ->
    @button = @$ "button"
    @input = @$ "input"

    @button.click (e) =>
      e.preventDefault()
      # $.cookies.set "secret", @input.val()
      document.cookie = "secret=#{ @input.val() }"
      window.location.reload()

  ask: ->
    $(@el).lightbox_me
      closeClick: false

class views.Secret extends Backbone.View
  el: '.secret'

  constructor: (opts) ->
    super


    @toggle = @$('#toggle_secret')
    @hidden = @$('#secret')
    @plain = @$('#secret_clear').hide()
    @isPlainText = false

    @hidden.edited => @trigger "change"
    @plain.edited => @trigger "change"

    @toggle.click (e) =>
      if @isPlainText
        @hidden.val(@plain.hide().val()).show().focus()
        @toggle.text('Show')
      else
        @plain.val(@hidden.hide().val()).show().focus()
        @toggle.text('Hide')

      @isPlainText = !@isPlainText

      e.preventDefault()

  setSecret: (secret) ->
    @plain.val secret
    @hidden.val secret

  getSecret: ->
    if @isPlainText
      return @plain.val()
    else
      return @hidden.val()
