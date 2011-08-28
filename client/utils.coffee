
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
    <div class="slide">
      <h3>Add slides</h3>
      <p>Slide content is simple HTML.</p>
    </div>
    <div class="slide">
      <h3>Click save</h3>
      <p>The Slide Show is saved and public URL becomes available.</p>
    </div>
  </div>

  <div class="slide">
    <h2>Example: Embed video</h2>
    <iframe src="http://player.vimeo.com/video/14784101?portrait=0" width="500" height="290" frameborder="0"></iframe>
  </div>

  <div class="slide">
    <h2>Learn more</h2>
    <ul>
      <div class="slide">
        <li><a href="#">Flips.io presentation</a></li>
        <li><a href="http://imakewebthings.github.com/deck.js/introduction/">Deck.js presentation</a></li>
      </div>
    </ul>

    <div class="slide">
      <h3>Thanks and don't forget to vote! :)</h3>
    </div>
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

`window.docCookies = {
  getItem: function (sKey) {
    if (!sKey || !this.hasItem(sKey)) { return null; }
    return unescape(document.cookie.replace(new RegExp("(?:^|.*;\\s*)" + escape(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=\\s*((?:[^;](?!;))*[^;]?).*"), "$1"));
  },
  /**
  * docCookies.setItem(sKey, sValue, vEnd, sPath, sDomain, bSecure)
  *
  * @argument sKey (String): the name of the cookie;
  * @argument sValue (String): the value of the cookie;
  * @optional argument vEnd (Number, String, Date Object or null): the max-age in seconds (e.g., 31536e3 for a year) or the
  *  expires date in GMTString format or in Date Object format; if not specified it will expire at the end of session; 
  * @optional argument sPath (String or null): e.g., "/", "/mydir"; if not specified, defaults to the current path of the current document location;
  * @optional argument sDomain (String or null): e.g., "example.com", ".example.com" (includes all subdomains) or "subdomain.example.com"; if not
  * specified, defaults to the host portion of the current document location;
  * @optional argument bSecure (Boolean or null): cookie will be transmitted only over secure protocol as https;
  * @return undefined;
  **/
  setItem: function (sKey, sValue, vEnd, sPath, sDomain, bSecure) {
    if (!sKey || /^(?:expires|max\-age|path|domain|secure)$/.test(sKey)) { return; }
    var sExpires = "";
    if (vEnd) {
      switch (typeof vEnd) {
        case "number": sExpires = "; max-age=" + vEnd; break;
        case "string": sExpires = "; expires=" + vEnd; break;
        case "object": if (vEnd.hasOwnProperty("toGMTString")) { sExpires = "; expires=" + vEnd.toGMTString(); } break;
      }
    }
    document.cookie = escape(sKey) + "=" + escape(sValue) + sExpires + (sDomain ? "; domain=" + sDomain : "") + (sPath ? "; path=" + sPath : "") + (bSecure ? "; secure" : "");
  },
  removeItem: function (sKey) {
    if (!sKey || !this.hasItem(sKey)) { return; }
    var oExpDate = new Date();
    oExpDate.setDate(oExpDate.getDate() - 1);
    document.cookie = escape(sKey) + "=; expires=" + oExpDate.toGMTString() + "; path=/";
  },
  hasItem: function (sKey) { return (new RegExp("(?:^|;\\s*)" + escape(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=")).test(document.cookie); }
};`
