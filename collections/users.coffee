_ = require 'underscore'
Backbone = require 'backbone'
sd = require('sharify').data
User = require '../models/user.coffee'

module.exports = class Users extends Backbone.Collection
  url: "#{sd.API_URL}/users"
