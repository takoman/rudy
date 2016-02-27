_ = require 'underscore'
Backbone = require 'backbone'

module.exports.HomeView = class HomeView extends Backbone.View
  initialize: ->
    undefined

module.exports.init = ->
  new HomeView el: $ 'body'
