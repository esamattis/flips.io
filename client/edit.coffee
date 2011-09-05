utils = NS "FLIPS.utils"
remote = NS "FLIPS.remote"
{SlideShowModel} = FLIPS.models
{AskSecret, Links, Editor, Preview, Secret} = NS "FLIPS.edit.views"


class FLIPS.Workspace extends Backbone.Router

  routes:
    "": "start"
    "edit/:id": "edit"

  initViews: (opts={}) ->
    console.log "initing views"
    model = new SlideShowModel opts

    @globalRemote = new remote.RemoteSocket model

    @askSecret = new AskSecret
      el: ".ask_secret"
      model: model

    @links = new Links
      el: '.toolbar'
      model: model

    @editor = new Editor
      el: ".edit_view"
      model: model

    @preview = new Preview
      el: ".preview"
      model: model

    # @editor.bind "editposition", (currentSlideIndex) =>
    #   @preview.iframeRemote.goto currentSlideIndex


    model.bind "saved", =>
      # TODO: update
      @globalRemote.reload()

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



