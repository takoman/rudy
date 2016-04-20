#
# The client-side code for the commits page.
#
# [Browserify](https://github.com/substack/node-browserify) lets us write this
# code as a common.js module, which means requiring dependecies instead of
# relying on globals. This module exports the Backbone view and an init
# function that gets used in /assets/commits.coffee. Doing this allows us to
# easily unit test these components, and makes the code more modular and
# composable in general.
#

Q = require 'q'
sd = require("sharify").data
Backbone = require "backbone"
CurrentUser = require "../../models/current_user.coffee"

module.exports.AuthView = class AuthView extends Backbone.View
  events:
    'submit form': 'maybeClientSideLogin'

  initialize: ->
    @user = CurrentUser.orNull()

  maybeClientSideLogin: (e) ->
    $form = $ e.target
    isClientSideLogin = $form.find('[name="client-side"]').prop("checked")
    if isClientSideLogin
      e.preventDefault()
      Q($.post($form.prop('action'), $form.serialize()))
        .then (data) =>
          @$('.auth-info-content').html JSON.stringify(data, null, 2)
        .catch (error) =>
          @$('.auth-info-content').html JSON.stringify(error, null, 2)
        .done()

module.exports.init = ->
  new AuthView el: $ "body"
