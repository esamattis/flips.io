
express = require 'express'
stylus = require 'stylus'
nib = require 'nib'

compile = (str, path) ->
  stylus(str).set("filename", path).use(nib())

{addCodeSharingTo} = require("express-share")

app = module.exports = express.createServer()

# Configuration

app.configure ->
  addCodeSharingTo app
  app.shareFs __dirname + "/client/vendor/jquery.js"
  app.shareFs __dirname + "/client/vendor/underscore.js"
  app.shareFs __dirname + "/client/vendor/backbone.js"
  app.shareFs __dirname + "/client/vendor/deck.js/deck.core.js"
  app.shareFs __dirname + "/client/vendor/deck.js/modernizr.custom.js"
  app.shareFs __dirname + "/client/namespace.js"
  app.shareFs __dirname + "/client/main.coffee"

  # Bug? Does not work under stylesheets dirs
  app.use stylus.middleware
    src: __dirname + "/public"
    compile: compile

  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  # app.use app.router
  app.use express.static __dirname + '/public'

app.configure 'development', ->
  app.use express.errorHandler dumpExceptions: true, showStack: true

app.configure 'production', ->
  app.use express.errorHandler()


