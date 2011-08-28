$ = jQuery

utils = NS "FLIPS.utils"


SlideShowModel = FLIPS.models.SlideShowModel

class Editor extends Backbone.View
  el: ".edit_view"


  constructor: (opts) ->
    super
    @saveButton = $ "#save"
    @saveButton.click => @save()

    @initAce()

    @model.bind "initialfetch", (e) =>
      if e.source is "default"
        @showUnsavedNotification()
      else
        @hideUnsavedNotification()

      @setEditorContents @model.get "html"

      @editor.getSession().on "change", =>
        console.log "CHANGE"
        @showUnsavedNotification()


    @model.fetch()

  setEditorContents: (code) ->
    @editor.getSession().setValue code

  initAce: ->
    @editor = ace.edit "editor"
    @editor.setShowPrintMargin false
    HTMLmode = require("ace/mode/html").Mode
    session = @editor.getSession()
    session.setTabSize(2);
    # session.setUseWrapMode(true);
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
    @model.set html: html
    @model.save null,
      success: (e) =>
        @model.trigger "saved", @model
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
    @model.bind "saved", => @reload()
    @model.bind "initialfetch", =>
      @reload()


  reload: ->
    console.log "RELOADING PREVIEW", @model.id
    if @iframe.attr("src") is "/initial"
      @iframe.attr "src", @model.getPresentationURL()
      console.log "setting iframe to real url #{ @iframe.attr "src" }"
    else
      console.log "reloading iframe via socket"
      @socket.emit "manage",
        target: @model.get "id"
        name: "reload"



# Refactor to listen to model's init and change events?
class Links extends Backbone.View
  el: '.toolbar'

  constructor: (opts) ->
    super
    @publicLink = @$('.public_link a')
    @remoteLink = @$('.remote_link a')
    @model.bind "change:id", => @render()
    @model.bind "initialfetch", => @render()

  render: ->
    @publicLink.attr('href',@model.getPresentationURL()).show "slow"
    @remoteLink.attr('href', @model.getRemoteURL()).show "slow"

class FLIPS.Workspace extends Backbone.Router

  routes:
    "": "start"
    "edit/:id": "edit"


  initViews: (opts={}) ->
    console.log "initing views"
    model = new SlideShowModel opts

    @links = new Links
      model: model

    @editor = new Editor
      model: model

    @preview = new Preview
      el: ".preview"
      model: model


  edit: (id) ->
    console.log "EDIT ROUTE", id

    if @editor?.getDocId() isnt id
      console.log "Id changed!, initing views"
      @initViews id: id


  start: ->
    console.log "START ROUTE"
    @initViews()



