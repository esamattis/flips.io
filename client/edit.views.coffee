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
    @secret.bind "change", =>
      @showUnsavedNotification()

    @saveButton = $ "#save"
    @saveButton.tipsy
      gravity: 's',
      opacity: 1
    @saveButton.click => @save()

    @initAce()

    @modeEl = @$('#mode')
    @modeEl.change =>
      @setMode()
      @showUnsavedNotification()

    @model.bind "initialfetch", (e) =>
      if e.source is "default"
        @showUnsavedNotification()
      else
        @hideUnsavedNotification()

      @setEditorContents @model.get "code"

      @modeEl.val(@model.get "mode")
      @setMode()

      @secret.setSecret @model.get "secret"

      @editor.getSession().on "change", =>
        console.log "CHANGE"
        @showUnsavedNotification()

  setMode: ->
    @editor.getSession().setMode(@modes[@modeEl.val()])

  setEditorContents: (code) ->
    @editor.getSession().setValue code

  initAce: =>
    @editor = ace.edit "editor"
    @editor.setShowPrintMargin false
    session = @editor.getSession()
    session.setTabSize(2);
    @setMode


    # Hide the line numbering, doesn't work perfectly
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
    code = @editor.getSession().getValue()
    mode = @modeEl.val()

    @model.set
      code: code,
      mode: mode,
      secret: @secret.getSecret()

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

    @model.bind "change:id", => @reload()
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

    @publicLink.tipsy
      gravity: 's',
      opacity: 1
    @remoteLink.tipsy
      gravity: 's',
      opacity: 1

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

    @$('label').tipsy
      gravity: 's',
      opacity: 1

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
