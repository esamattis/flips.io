$ = jQuery
mock = """<div class="slide" id="title-slide">
                <h1>Getting Started with deck.js</h1>
        </div>

        <div class="slide" id="how-to-overview">
                <h2>How to Make a Deck</h2>
                <ol>
                        <li>
                                <h3>Write Slides</h3>
                                <p>Slide content is simple&nbsp;HTML.</p>
                        </li>
                        <li>
                                <h3>Choose Themes</h3>
                                <p>One for slide styles and one for deck&nbsp;transitions.</p>
                        </li>
                        <li>
                                <h3>Include Extensions</h3>
                                <p>Add extra functionality to your deck, or leave it stripped&nbsp;down.</p>
                        </li>
                </ol>
        </div>"""

class Slide extends Backbone.Model

  urlRoot: "/slides"

  hello: ->
    alert "hello"

class LightBox extends Backbone.View

  error: (msg) ->
    alert "ERROR: #{ msg }"

  warning: (msg) ->
    alert "WARNING: #{ msg }"

  info: (msg) ->
    alert "INFO: #{ msg }"

  hide: ->

class Editor extends Backbone.View
  el: ".edit_view"

  constructor: (opts) ->
    super opts
    @editor = ace.edit(opts.editor)
    HTMLmode = require("ace/mode/html").Mode
    @editor.getSession().setMode(new HTMLmode())
    
    @model.bind "change", (slide) =>
      @editor.getSession().setValue slide.get "html"

    @model.fetch()


  events:
    "click .save": "save"

  save: ->
    html = @editor.getSession().getValue()
    console.log "saving", html, @model
    @model.set html: html
    @model.save null,
      success: (e) =>
        console.log "we have now id", @model.get("id")
        if not @hasEditUrl()
          window.location.hash = "#edit/#{ @model.get("id") }"

      error: (e, err) =>
        console.log "failed to save", @model, e, err

  hasEditUrl: -> !!window.location.hash

class Workspace extends Backbone.Router

  constructor: (opts) ->
   super opts
   messages = new LightBox

  routes:
    "": "start"
    "edit/:id": "edit"

  edit: (id) ->
    console.log "edit", id
    @editor = new Editor
      editor: "editor"
      model: new Slide
        id: id

  start: ->
    console.log "start"
    @editor = new Editor
      editor: "editor"
      model: new Slide
    @editor.model.set html: mock


$ ->
  ws = new Workspace
  Backbone.history.start()


