fs = require "fs"

express = require 'express'
stylus = require 'stylus'
nib = require 'nib'
io = require 'socket.io'
everyauth = require 'everyauth'
Promise = everyauth.Promise
users = require './users'

piles = require "piles"
js = piles.createJSManager()
css = piles.createCSSManager()

everyauth.everymodule.findUserById (userId, callback) ->
  console.log "ASDFAFDDD"
  # callback("lol", users.findUser(userId))


# Setup authentication providers
everyauth.github
  .appId('f648c6f2e0a50097eaa1')
  .appSecret('3ac69da84d13b9cffc19465e38134a89272583c3')
  .findOrCreateUser (session, accessToken, accessTokenExtra, githubUserMetadata) ->
    promise = new Promise()
    
    users.findOrCreateUserGithub(githubUserMetadata, promise)
    
    return true
    
    # console.log session
    # console.log accessToken
    # console.log accessTokenExtra
    # console.log githubUserMetadata
    # debugger
    # return false
    # find or create user logic goes here
  .redirectPath('/')
  .callbackPath('/auth/github/callback')



app = express.createServer()

io = require('socket.io').listen app

io.configure ->
  io.set 'log level', 0

exports.app = app
exports.io = io

# Configuration
app.configure ->
  app.use express.bodyParser()
  app.use express.cookieParser()

  app.use express.session {secret: "90ndsj9dfdsf"}
  app.use everyauth.middleware()

  
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  # app.use express.methodOverride()
  # app.use app.router
  app.use express.static __dirname + '/public'

everyauth.helpExpress(app)

app.configure ->
  js.bind app
  css.bind app

  # Global assets
  js.addUrl "/socket.io/socket.io.js"
  js.addFile __dirname + "/client/vendor/jquery.js"
  js.addFile __dirname + "/client/vendor/underscore.js"
  js.addFile __dirname + "/client/vendor/backbone.js"
  js.addFile __dirname + "/client/namespace.js"
  js.addFile __dirname + "/client/vendor/jquery.jgrowl.js"
  js.addFile __dirname + "/client/vendor/jquery.tipsy.js"
  js.addFile __dirname + "/client/vendor/jquery.lightbox_me.js"

  js.addFile __dirname + "/client/utils.coffee"
  js.addFile __dirname + "/client/models.coffee"
  js.addFile __dirname + "/client/mobile.coffee"

  css.addFile __dirname + "/public/stylesheets/jquery.jgrowl.css"
  css.addFile __dirname + "/public/stylesheets/tipsy.css"

  # Editor assets
  js.addFile "editor", __dirname + "/public/javascripts/ace/ace.js"
  js.addFile "editor", __dirname + "/public/javascripts/ace/mode-html.js"
  js.addFile "editor", __dirname + "/public/javascripts/ace/jade-highlighter/mode-jade.js"
  js.addFile "editor", __dirname + "/client/edit.views.coffee"
  js.addFile "editor", __dirname + "/client/edit.coffee"

  css.addUrl "editor", "http://fonts.googleapis.com/css?family=Leckerli+One"
  css.addFile "editor", __dirname + "/public/stylesheets/bootstrap-1.1.1.min.css"
  css.addFile "editor", __dirname + "/public/styles.styl"
  css.addFile "editor", __dirname + "/public/scrollbars.styl"


  # Slideshow assets
  js.addFile "slideshow", __dirname + "/client/slideshow.coffee"

  # Does not work when minified to a one file
  js.addUrl "slideshow", "/javascripts/jade.js"

  js.addFile "slideshow", __dirname + "/public/deck.js/modernizr.custom.js"
  js.addFile "slideshow", __dirname + "/public/deck.js/core/deck.core.js"
  js.addFile "slideshow", __dirname + "/public/deck.js/extensions/goto/deck.goto.js"
  js.addFile "slideshow", __dirname + "/public/deck.js/extensions/hash/deck.hash.js"
  js.addFile "slideshow", __dirname + "/public/deck.js/extensions/menu/deck.menu.js"
  js.addFile "slideshow", __dirname + "/public/deck.js/extensions/navigation/deck.navigation.js"
  js.addFile "slideshow", __dirname + "/public/deck.js/extensions/status/deck.status.js"
  js.addFile "slideshow", __dirname + "/public/deck.js/extensions/notes/deck.notes.js"

  css.addFile "slideshow", __dirname + "/public/deck.js/core/deck.core.css"
  css.addFile "slideshow", __dirname + "/public/deck.js/extensions/goto/deck.goto.css"
  css.addFile "slideshow", __dirname + "/public/deck.js/extensions/hash/deck.hash.css"
  css.addFile "slideshow", __dirname + "/public/deck.js/extensions/menu/deck.menu.css"
  css.addFile "slideshow", __dirname + "/public/deck.js/extensions/navigation/deck.navigation.css"
  css.addFile "slideshow", __dirname + "/public/deck.js/extensions/status/deck.status.css"
  css.addFile "slideshow", __dirname + "/public/deck.js/extensions/notes/deck.notes.css"



app.configure 'development', ->
  console.log "pid is", process.pid
  fs.writeFile __dirname + "/flips.pid", "#{ process.pid }".trim()
  app.use express.errorHandler dumpExceptions: true, showStack: true


app.configure 'production', ->
  app.use express.errorHandler()


