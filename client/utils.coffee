
utils = NS "FLIPS.utils"
S4 = ->
  (((1 + Math.random()) * 65536) | 0).toString(16).substring(1)

if not window.console?.log?
  window.console =
    log: ->


utils.guidGenerator = ->
  (S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4())

utils.mock = """<div class="slide">
    <h1>Getting Started with Flips.IO</h1>
  </div>

  <div class="slide">
    <h2>How to Make a Slide?</h2>
    <ol>
      <li>
        <h3>Add a slide</h3>
        <p>&lt;div class="slide"&gt;...&lt;/div&gt;</p>
        <p>Slide content is simple HTML.</p>
      </li>
    </ol>
  </div>

  <div class="slide">
    <h2>Embed Pics</h2>
    <img src="http://i.imgur.com/1GJOC.jpg" alt="" title="Hosted by imgur.com" />
  </div>

  <div class="slide">
    <h2>Embed video</h2>
    <iframe width="560" height="345" src="http://www.youtube.com/embed/6Io3aSEkG_s" frameborder="0" allowfullscreen></iframe>
  </div>"""

utils.getSocket = -> io.connect window.location.origin

log = console.log
console.log = (msg, others...) ->
  msg = "#{ window.location.href }: #{ msg }"
  others.unshift msg
  log.apply this, others


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
