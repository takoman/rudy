_ = require 'underscore'
Backbone = require "backbone"

module.exports.StyleGuideView = class StyleGuideView extends Backbone.View
  initialize: ->
    undefined

module.exports.init = ->
  new StyleGuideView el: $ "body"
