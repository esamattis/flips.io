
S4 = ->
  (((1 + Math.random()) * 65536) | 0).toString(16).substring(1)

utils = NS "FLIPS.utils"

utils.guidGenerator = ->
  (S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4())

utils.mock = """<div class="slide">
    <h1>Getting Started with Flips.io</h1>
  </div>

  <div class="slide">
    <h2>How to Make a Slide?</h2>
    <ol>
      <li>
        <h3>Add a slide</h3>
        <p>&lt;div class="slide"&gt;...&lt;/div&gt;</p>
        <p>Slide content is simple HTML.</p>
      </li>
      <li>
        <h3>Choose Thememks</h3>
        <p>One for slide styles and one for deck transitions.</p>
      </li>
      <li>
        <h3>Include Extensions</h3>
        <p>Add extra functionality to youreck, or leave it stripped own.</p>
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
