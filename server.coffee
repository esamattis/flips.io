# Module dependencies.

_  = require 'underscore'
_.mixin require 'underscore.string'

app = module.exports = require "./configure"

db = require "./db"

app.get "/laskuri", (req, res) ->
  db.getAlways "laskuri", count: 0, (err, doc) ->
    count = doc.count + 1
    console.log "saving", doc.count
    db.save "laskuri", count: count, (err, couchres) ->
      if err
        console.log err
        res.end "err #{ JSON.stringify err }"
        return
      res.end "count: #{ doc.count }"


# Slide mock
mock =
  content: '<div class="slide" id="title-slide">
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
        </div>'

# Routes

app.get '/', (req, res) ->
  res.render 'index',
    title: 'Express'

app.post "/slides", (req, res) ->
  console.log "body", req.body
  res.end()

app.put "/slides/:id", (req, res) ->
  console.log "body", req.body
  res.end()


app.get "/slides/:id", (req, res) ->
  res.contentType('json')
  console.log "params", req.params
  res.end JSON.stringify
    foo: "bar"
    id2: "id2 #{ req.params.id }"


# app.get '/:id', (req, res) ->
#   res.render('slide', title: "Slide #{req.params.id}", slide: mock)
# 
# 
# app.get '/api/:id', (req, res) ->
#   res.send mock



if require.main is module
  app.listen(8000)
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env)

