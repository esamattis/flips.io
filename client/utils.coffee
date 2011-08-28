
utils = NS "FLIPS.utils"
S4 = ->
  (((1 + Math.random()) * 65536) | 0).toString(16).substring(1)

if not window.console?.log?
  window.console =
    log: ->

jQuery.fn.edited = (callback) ->
    this.each ->
        that = $(this)

        active = false


        that.focusin ->
            active = true
        that.focusout ->
            active = false

        $(window).keyup ->
            callback(that) if active

utils.guidGenerator = ->
  (S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4())

utils.mock = """<div class="slide">
    <h1>Getting Started with Flips.IO</h1>
  </div>

  <div class="slide">
    <h2>Create Slide Show</h2>
    <h3>Add slides</h3>
    <p>Slide content is simple HTML.</p>
    <pre>&lt;div class="slide"&gt;
    &lt;h1&gt;Hello World!&lt;/h1&gt;
  &lt;/div&gt;</pre>
  </div>

  <div class="slide">
    <h2>Example: Embed video</h2>
    <iframe width="420" height="345" src="http://www.youtube.com/embed/oHg5SJYRHA0" frameborder="0" allowfullscreen></iframe>
  </div>

  <div class="slide">
    <h2>Powered by</h2>
    <a href="http://imakewebthings.github.com/deck.js/" target="_blank"><img src="http://i.imgur.com/J8ReH.png" />
    <a href="http://ajaxorg.github.com/ace/" target="_blank"><img src="http://i.imgur.com/M1zIC.png" /></a>
    <a href="http://nodejs.org/" target="_blank"><img src="http://i.imgur.com/xdNvu.png" /></a>
    <a href="http://couchdb.apache.org/" target="_blank"><img src="http://i.imgur.com/QnwKY.png" /></a>
    <p align="center">also <a href="http://socket.io/" target="_blank">Socket.IO</a>, <a href="http://expressjs.com/" target="_blank">Express</a>, <a href="http://documentcloud.github.com/backbone/" target="_blank">Backbone.js</a> and many more</p>
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
