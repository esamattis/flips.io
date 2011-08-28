$ = jQuery

utils = NS "FLIPS.utils"


SlideShow = FLIPS.models.SlideShow

class Editor extends Backbone.View
  el: ".edit_view"


  constructor: (opts) ->
    super
    @saveButton = $ "#save"
    @saveButton.click => @save()

    @initAce()

    @model.bind "change", (slide) =>
      @editor.getSession().setValue slide.get "html"
      # console.log "changed", JSON.stringify @model.attributes

    if @model.get "id"
      @model.fetch
        success: =>
          @trigger 'init', @


  initAce: ->
    @editor = ace.edit "editor"
    @editor.setShowPrintMargin false
    HTMLmode = require("ace/mode/html").Mode
    @editor.getSession().setTabSize(2);
    # @editor.getSession().setUseWrapMode(true);
    @editor.getSession().setMode(new HTMLmode())


    # Hide the line numbering, doesn't work perfectly
    lineNumberWidth = parseInt($(".ace_scroller").css('left'))
    $(".ace_scroller").css('left', '0px')
    $(".ace_gutter").hide()
    $(".ace_scroller").css('width',  parseInt($(".ace_scroller").css('width')) + lineNumberWidth)


  getDocId: ->
    @model.get "id"



  save: ->
    html = @editor.getSession().getValue()
    # console.log "saving", JSON.stringify @model.attributes
    @model.set html: html
    @model.save null,
      success: (e) =>
        utils.msg.info "saved #{ @model.get "id" }"
        @model.trigger "saved", @model

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
    utils.msg.info "Saved and reloading preview now"

# Refactor to listen to model's init and change events?
# class Links extends Backbone.View
#   el: '#links'
#
#   constructor: (opts) ->
#     super
#
#     @id = opts.id
#     @publicLink = @$('#public_link')
#     @remoteLink = @$('#remote_link')
#
#   render: ->
#     @publicLink.attr('href', "/view/#{@id}").show()
#     @remoteLink.attr('href', "/r/#{@id}").show()

class FLIPS.Workspace extends Backbone.Router

  routes:
    "": "start"
    "edit/:id": "edit"

  constructor: (opts) ->
    super

    @preview = new Preview
      el: ".preview"

    # @links = new Links

  initEditor: (model) ->
    @editor = new Editor model: model

    @editor.bind "init", =>
      @preview.id = model.get "id"
      @preview.reload()

    model.bind "saved", =>
      @preview.id = model.get "id"
      @preview.reload()

  edit: (id) ->
    console.log "edit", id
    if @editor?.getDocId() isnt id
      ss = new SlideShow
        id: id

      @initEditor ss


  start: ->
    console.log "start"
    @initEditor new SlideShow
    @editor.model.set html: utils.mock



