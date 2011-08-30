utils = NS "FLIPS.utils"
{SlideShowModel} = FLIPS.models
{AskSecret, Links, Editor, Preview, Secret} = NS "FLIPS.edit.views"


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



