utils = NS "FLIPS.utils"
remote = NS "FLIPS.remote"
{SlideShowModel} = FLIPS.models
{AskSecret, Links, Editor, Preview, Secret} = NS "FLIPS.edit.views"

$ ->
  windowWidth = $(window).width()
  editor = $ "#editor"
  preview = $ ".preview iframe"

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
    model = new SlideShowModel opts
    model.bind "initialfetch", =>
      console.log "BINDING"
      @editor.bind "editposition", (pos) =>
        @preview.iframeRemote.goto pos

      if model.get "readOnly"
        @askSecret.ask()

    @globalRemote = new remote.RemoteSocket model

    @askSecret = new AskSecret
      model: model

    @links = new Links
      model: model

    @editor = new Editor
      model: model

    @preview = new Preview
      model: model


    model.bind "saved", =>
      @globalRemote.update model.toJSON()


    $('[original-title]').tipsy
      gravity: 's',
      opacity: 1

    model.fetch()

  edit: (id) ->

    if @editor?.getDocId() isnt id
      console.log "Id changed!, initing views"
      @initViews id: id


  start: ->
    @initViews()



