
soda = require "soda"
_  = require 'underscore'
_.mixin require 'underscore.string'

helpers = require "./helpers"

browser = soda.createClient
  host: "localhost"
  port: 4444
  url: "http://localhost:8000/"
  browser: "firefox"

browser.on "command", (cmd, args) ->
  console.log(' \x1b[33m%s\x1b[0m: %s', cmd, args.join(', '))

editor = "css=#editor textarea"

jasmine.asyncSpecWait.timeout = 30 * 1000


describe "When saving", ->

  it "gives new url", ->
    asyncSpecWait()
    browser
      .chain
      .setSpeed(200)
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
        expect(url).toBe "http://localhost:8000/#edit/b"
      .testComplete()
      .end (err) ->
        if (err) then throw err
        asyncSpecDone()
        console.log('done')


testSlide = """
<div class=\"slide\">
  <h1>Slide 1</h1>
</div>

<div class=\"slide\">
  <h1>Slide 2</h1>
</div>
"""

describe "When moving cursor", ->


  it "changes the slide for me", ->
    asyncSpecWait()
    browser
      .chain
      .setSpeed(200)
      .session()
      .open('/')
      .focus(editor)
      .and (b) ->
        for i in [0...9]
          b.keyDown(editor, '\\40')
      .selectFrame("css=iframe")
      .getLocation (url) ->
        expect(url).toBe "http://localhost:8000/start/initial#slide-2"
      .testComplete()
      .end (err) ->
        if (err) then throw err
        asyncSpecDone()
        console.log('done')


  it "changes the slide for me even when I have saved", ->
    asyncSpecWait()
    browser
      .chain
      .setSpeed(200)
      .session()
      .open('/')
      .click("id=save") # Save!
      .focus(editor)
      .and (b) ->
        for i in [0...9]
          b.keyDown(editor, '\\40')
      .selectFrame("css=iframe")
      .getLocation (url) ->
        expect(url).toBe "http://localhost:8000/c#slide-2"
      .testComplete()
      .end (err) ->
        if (err) then throw err
        asyncSpecDone()
        console.log('done')

