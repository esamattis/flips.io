$ = jQuery
utils = NS "FLIPS.utils"

SlideShow = FLIPS.models.SlideShow




class Editor extends Backbone.View
  el: ".edit_view"

  constructor: (opts) ->
    super opts
    @editor = ace.edit "editor"
    HTMLmode = require("ace/mode/html").Mode
    @editor.getSession().setMode(new HTMLmode())

    @model.bind "change", (slide) =>
      @editor.getSession().setValue slide.get "html"
      # console.log "changed", JSON.stringify @model.attributes
      @$("textarea").val slide.get "html"

    @model.fetch()

  getDocId: ->
    @model.get "id"


  events:
    "click .save": "save"

  save: ->
    html = @editor.getSession().getValue()
    # console.log "saving", JSON.stringify @model.attributes
    @model.set html: html
    @model.save null,
      success: (e) =>
        utils.msg.info "saved #{ @model.get "id" }"
        setTimeout =>
          @model.trigger "saved", @model
        , 1000

        if not @hasEditUrl()
          window.location.hash = "#edit/#{ @model.get("id") }"

      error: (e, err) =>
        console.log "failed to save", @model, e, err
        utils.msg.error "failed to save #{ @model.get "id" }", true

  hasEditUrl: -> !!window.location.hash



class Preview extends Backbone.View

  constructor: (opts) ->
    super
    @id = opts.id
    @iframe = @$("iframe")

  reload: ->
    console.log "RELOADING PREVIEW", @id
    @iframe.attr "src", ""
    @iframe.attr "src", "/view/#{ @id }"


class FLIPS.Workspace extends Backbone.Router

  routes:
    "": "start"
    "edit/:id": "edit"

  constructor: (opts) ->
   super
   @preview = new Preview
    el: ".preview"

  initEditor: (model) ->
    @editor = new Editor model: model
    model.bind "saved", =>
      @preview.id = model.get "id"
      @preview.reload()

  edit: (id) ->
    console.log "edit", id
    if @editor?.getDocId() isnt id
      @initEditor new SlideShow
        id: id

  start: ->
    console.log "start"
    @initEditor new SlideShow
    @editor.model.set html: utils.mock



