utils = NS "FLIPS.utils"
remote = NS "FLIPS.remote"
{SlideShowModel} = FLIPS.models
{AskSecret, Links, Editor, Preview, Secret} = NS "FLIPS.edit.views"

$ ->
  windowWidth = $(window).width()
  editor = $ "#editor"
  preview = $ ".preview iframe"
  $(".ace_sb").mousedown ->
    console.log "DOWN"

  $(window).mousemove _.throttle (e) ->
      return
      pos = e.pageX / windowWidth * 100
      console.log "win", pos
      editor.css width: pos + "%"
      preview.css left: pos + "%"
    , 100


class FLIPS.Workspace extends Backbone.Router

  routes:
    "": "start"
    "edit/:id": "edit"

  initViews: (opts={}) ->
    console.log "initing views"
    model = new SlideShowModel opts

    @globalRemote = new remote.RemoteSocket model

    @askSecret = new AskSecret
      model: model

    @links = new Links
      model: model

    @editor = new Editor
      model: model

    @preview = new Preview
      model: model

    # @editor.bind "editposition", (currentSlideIndex) =>
    #   @preview.iframeRemote.goto currentSlideIndex

    model.bind "saved", =>
      @globalRemote.update model.toJSON()

    $('[original-title]').tipsy
      gravity: 's',
      opacity: 1

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



