
class Slide extends Backbone.Model

  urlRoot: "/slides"

  hello: ->
    alert "hello"


$ ->
  slide = new Slide id: "slide-sdf"
  # slide.set foo: "bar"
  # slide.set lol: "jee"
  # slide.save()

  slide.fetch()
  slide.bind "change", ->
    console.log slide.toJSON()
  console.log slide.toJSON()
