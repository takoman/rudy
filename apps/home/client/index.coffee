Q = require 'q'
_ = require 'underscore'
Backbone = require 'backbone'
User = require '../../../models/user.coffee'

module.exports.HomeView = class HomeView extends Backbone.View
  events:
    'submit .user-search-form': 'fetchAndRenderUser'

  initialize: -> undefined

  fetchAndRenderUser: (e) ->
    e.preventDefault()

    $form = $ e.target
    id = $form.find('input[name="id"]').val()
    Q((user = new User(id: id)).fetch())
      .then =>
        @$('.user-info').html "User email: #{user.get('email')}"
      .catch =>
        @$('.user-info').html 'Error'
      .done()

module.exports.init = ->
  new HomeView el: $ 'body'
