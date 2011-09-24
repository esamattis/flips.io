
async = require "async"
{nextUrl} = require "../lib/shorturlgenerator"
db = require "../lib/db"
{encode, decode} = require "../lib/urlshortener"
helpers = require "./helpers"

describe "url generator gives unique urls", ->

  beforeEach helpers.resetDB jasmine


  it "get b as first", ->
    jasmine.asyncSpecWait()

    nextUrl (err, url) ->
      throw err if err
      expect(url).toBe "b"
      jasmine.asyncSpecDone()


  createUrlTasks = (count) ->
    urls = {}
    tasks = []
    for i in [0...count]
      tasks.push (cb) ->
        nextUrl (err, url) ->
          return cb err if err

          if urls[url]
            urls[url] += 1
          else
            urls[url] = 1

          cb null

    return [urls, tasks]

  it "skips r because it is reserved", ->
    jasmine.asyncSpecWait()
    [urls, tasks] = createUrlTasks 100

    async.series tasks, ->

      expect(urls.q).toBeDefined()
      expect(urls.r).toBeUndefined()
      expect(urls.s).toBeDefined()

      expect(urls.m).toBeUndefined()
      expect(urls.n).toBeDefined()

      jasmine.asyncSpecDone()


  it "works parallel too", ->
    jasmine.asyncSpecWait()
    count = 50
    [urls, tasks] = createUrlTasks count
    async.parallel tasks, (err) ->
      throw err if err

      expect(Object.keys(urls).length).toBe count, "we asked for #{ count } urls"

      for k, v of urls
        expect(v).toBe 1, "we have gotten url '#{ k }' more than once!"

      expect(urls.r).toBeUndefined()
      expect(urls.m).toBeUndefined()

      jasmine.asyncSpecDone()








