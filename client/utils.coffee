
S4 = ->
  (((1 + Math.random()) * 65536) | 0).toString(16).substring(1)

utils = NS "FLIPS.utils"

utils.guidGenerator = ->
  (S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4())

utils.mock = """<div class="slide" id="title-slide">
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

utils.getSocket = -> io.connect window.location.origin

class Messaging extends Backbone.View

  show: (type, msg, modal) ->
    msg = "#{ type } #{ msg }"
    if modal
      alert msg
    else
      $.jGrowl msg

  info: (msg, modal) -> @show "INFO", msg, modal
  warning: (msg, modal) -> @show "WARNING", msg, modal
  error: (msg, modal) -> @show "ERROR", msg, modal

  hide: ->


$ ->
  utils.msg = new Messaging
