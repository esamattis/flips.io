# Module dependencies.

_  = require 'underscore'
_.mixin require 'underscore.string'

app = module.exports = require "./configure"

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

# app.get '/:id', (req, res) ->
#   res.render('slide', title: "Slide #{req.params.id}", slide: mock)
# 
# 
# app.get '/api/:id', (req, res) ->
#   res.send mock



if require.main is module
  app.listen(8000)
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env)

