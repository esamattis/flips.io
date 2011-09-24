
soda = require("soda")
_  = require 'underscore'
_.mixin require 'underscore.string'

browser = soda.createClient
  host: "localhost"
  port: 4444
  url: "http://localhost:8000/"
  browser: "firefox"

browser.on "command", (cmd, args) ->
  console.log " [33mundefined[0m: undefined", cmd, args.join(", ")

editor = "css=#editor textarea"

jasmine.asyncSpecWait.timeout = 30 * 1000

describe "When saving", ->
  it "gives new url", ->
    jasmine.asyncSpecWait()
    browser
      .chain
      .session()
      .open('/')
      .focus(editor)
      .controlKeyDown()
      .keyDown(editor, "a")
      .controlKeyUp()
      .typeKeys(editor, " ")
      .typeKeys(editor, "hello")
      .click("id=save")
      .getLocation (url) ->
        expect(_.startsWith url, "http://localhost:8000/#edit/").toBe true
      .testComplete()
      .end (err) ->
        if (err) then throw err
        jasmine.asyncSpecDone()
        console.log('done')


