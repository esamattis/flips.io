
utils = NS "FLIPS.utils"

# $ ->
#   $(".ask_secret").lightbox_me
#     closeClick: false
# 

SlideShowModel = FLIPS.models.SlideShowModel

class Editor extends Backbone.View
  el: ".edit_view"

  constructor: (opts) ->
    super

    @secret = new Secret
    @secret.bind "change", =>
      @showUnsavedNotification()

    @saveButton = $ "#save"
    @saveButton.tipsy
      gravity: 's',
      opacity: 1
    @saveButton.click => @save()

    @initAce()

    @model.bind "initialfetch", (e) =>
      if e.source is "default"
        @showUnsavedNotification()
      else
        @hideUnsavedNotification()

      @setEditorContents @model.get "html"
      @secret.setSecret @model.get "secret"

      @editor.getSession().on "change", =>
        console.log "CHANGE"
        @showUnsavedNotification()



  setEditorContents: (code) ->
    @editor.getSession().setValue code

  initAce: ->
    @editor = ace.edit "editor"
    @editor.setShowPrintMargin false
    HTMLmode = require("ace/mode/html").Mode
    session = @editor.getSession()
    session.setTabSize(2);
    session.setMode(new HTMLmode())


    # Hide the line numbering, doesn't work perfectly
    lineNumberWidth = parseInt($(".ace_scroller").css('left'))
    $(".ace_scroller").css('left', '0px')
    $(".ace_gutter").hide()
    $(".ace_scroller").css('width',  parseInt($(".ace_scroller").css('width')) + lineNumberWidth)

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
    html = @editor.getSession().getValue()
    @model.set
      html: html,
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



class Preview extends Backbone.View

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
class Links extends Backbone.View
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


class AskSecret extends Backbone.View
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

class Secret extends Backbone.View
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

class FLIPS.Workspace extends Backbone.Router

  routes:
    "": "start"
    "edit/:id": "edit"

  initViews: (opts={}) ->
    console.log "initing views"
    model = new SlideShowModel opts

    @askSecret = new AskSecret
      model: model

    @links = new Links
      model: model

    @editor = new Editor
      model: model

    @preview = new Preview
      el: ".preview"
      model: model

    model.fetch()
    model.bind "initialfetch", =>
      if model.get "readOnly"
        @askSecret.ask()

  edit: (id) ->
    console.log "EDIT ROUTE", id

    if @editor?.getDocId() isnt id
      console.log "Id changed!, initing views"
      @initViews id: id


  start: ->
    console.log "START ROUTE"
    @initViews()



