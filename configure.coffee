
express = require 'express'
stylus = require 'stylus'
nib = require 'nib'

compile = (str, path) ->
  stylus(str).set("filename", path).use(nib())

{addCodeSharingTo} = require("express-share")

app = module.exports = express.createServer()

# Configuration

app.configure ->
  app.use express.bodyParser()
  addCodeSharingTo app
  app.shareFs __dirname + "/client/vendor/jquery.js"
  app.shareFs __dirname + "/client/vendor/underscore.js"
  app.shareFs __dirname + "/client/vendor/backbone.js"
  
  # deck.js with extensions
  app.shareFs __dirname + "/client/vendor/deck.js/modernizr.custom.js"
  app.shareFs __dirname + "/client/vendor/deck.js/deck.core.js"
  app.shareFs __dirname + "/client/vendor/deck.js/deck.goto.js"
  app.shareFs __dirname + "/client/vendor/deck.js/deck.hash.js"
  app.shareFs __dirname + "/client/vendor/deck.js/deck.menu.js"
  app.shareFs __dirname + "/client/vendor/deck.js/deck.navigation.js"
  app.shareFs __dirname + "/client/vendor/deck.js/deck.status.js"  
  
  app.shareFs __dirname + "/client/vendor/ace/ace.js"
  app.shareFs __dirname + "/client/vendor/ace/mode-html.js"
  app.shareFs __dirname + "/client/namespace.js"
  app.shareFs __dirname + "/client/utils.coffee"
  app.shareFs __dirname + "/client/models.coffee"
  app.shareFs __dirname + "/client/main.coffee"
  app.shareFs __dirname + "/client/slideshow.coffee"

  # Bug? Does not work under stylesheets dirs
  app.use stylus.middleware
    src: __dirname + "/public"
    compile: compile

  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.methodOverride()
  # app.use app.router
  app.use express.static __dirname + '/public'

app.configure 'development', ->
  app.use express.errorHandler dumpExceptions: true, showStack: true

app.configure 'production', ->
  app.use express.errorHandler()


