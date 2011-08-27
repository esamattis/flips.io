$ = jQuery

class Slide extends Backbone.Model

  urlRoot: "/slides"

  hello: ->
    alert "hello"


class Editor extends Backbone.View
  el: ".edit_view"

  constructor: ->
    super
    @model.bind "change", (slide) =>
      @$("textarea").val slide.get "html"

    @model.fetch()


  events:
    "click .save": "save"

  save: ->
    html = @$("textarea").val()
    console.log "saving", html, @model
    @model.set html: html
    @model.save null,
      success: (e) =>
        console.log "we have now id", @model.get("id")
        if not @hasEditUrl()
          window.location.hash = "#edit/#{ @model.get("id") }"

      error: (e) =>
        console.log "failed to save", @model, e

  hasEditUrl: -> !!window.location.hash

class Workspace extends Backbone.Router

  constructor: (opts) ->
   super opts

  routes:
    "": "start"
    "edit/:id": "edit"

  edit: (id) ->
    console.log "edit", id
    @editor = new Editor
      model: new Slide
        id: id

  start: ->
    console.log "start"
    @editor = new Editor
      model: new Slide


$ ->
  ws = new Workspace
  Backbone.history.start()


