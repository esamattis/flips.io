$ = jQuery
utils = NS "FLIPS.utils"


class Slide extends Backbone.Model

  urlRoot: "/slides"

  hello: ->
    alert "hello"

  toJSON: ->
    html: @get "html"
    id: @get "id"


class Editor extends Backbone.View
  el: ".edit_view"

  constructor: (opts) ->
    super opts
    @editor = ace.edit(opts.editor)
    HTMLmode = require("ace/mode/html").Mode
    @editor.getSession().setMode(new HTMLmode())

    @model.bind "change", (slide) =>
      @editor.getSession().setValue slide.get "html"
      console.log "changed", JSON.stringify @model.attributes
      @$("textarea").val slide.get "html"

    @model.fetch()

  getDocId: ->
    @model.get "id"


  events:
    "click .save": "save"

  save: ->
    html = @editor.getSession().getValue()
    console.log "saving", JSON.stringify @model.attributes
    @model.set html: html
    @model.save null,
      success: (e) =>
        utils.msg.info "saved #{ @model.get "id" }", true

        if not @hasEditUrl()
          window.location.hash = "#edit/#{ @model.get("id") }"

      error: (e, err) =>
        console.log "failed to save", @model, e, err
        utils.msg.error "failed to save #{ @model.get "id" }", true

  hasEditUrl: -> !!window.location.hash

class Workspace extends Backbone.Router

  constructor: (opts) ->
   super opts

  routes:
    "": "start"
    "edit/:id": "edit"

  edit: (id) ->
    console.log "edit", id
    if @editor?.getDocId() isnt id
      @editor = new Editor
        model: new Slide
          id: id

  start: ->
    console.log "start"
    @editor = new Editor
      editor: "editor"
      model: new Slide
    @editor.model.set html: utils.mock


$ ->
  ws = new Workspace
  Backbone.history.start()


