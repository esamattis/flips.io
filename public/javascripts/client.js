(function() {
  var Slide;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  Slide = (function() {
    __extends(Slide, Backbone.Model);
    function Slide() {
      Slide.__super__.constructor.apply(this, arguments);
    }
    Slide.prototype.initialize = function() {
      return this.set({
        'id': '123'
      });
    };
    return Slide;
  })();
}).call(this);
