Backbone        = require 'backbone'
Backbone.$      = $
_               = require 'underscore'
sd              = require('sharify').data

module.exports = ->
  setupJquery()
  setupGlobal()

setupJquery = ->
  $.ajaxSettings.headers =
    'X-XAPP-TOKEN'  : sd.PICKEE_XAPP_TOKEN
    'X-ACCESS-TOKEN': sd.CURRENT_USER?.accessToken

# Setup global behaviors
setupGlobal = ->
  $('[data-toggle="tooltip"]').tooltip()
