request = require 'superagent'
moment = require 'moment'

module.exports.token = null

module.exports = (options) ->

  fetch = (callback) ->
    request.post("#{options.apiUrl}/tokens/xapp_token").query(
      client_id: options.clientId
      client_secret: options.clientSecret
    ).end (err, res) ->
      return callback err if err
      # NOTE: The endpoint returns an object:
      # { type: 'xapp_token', token: '...', expires_at: '...' }
      # We may want to double check if the type is actually "xapp_token."
      callback null, res.body.token
      expireTokenAt res.body.expires_at

  expireTokenAt = (expiresAt) ->
    setTimeout (-> module.exports.token = null), moment(expiresAt).unix() - moment().unix()

  (req, res, next) ->
    unless module.exports.token?
      fetch (err, token) ->
        return next(err) if err
        res.locals.pickeeXappToken = module.exports.token = token
        next()
    else
      res.locals.pickeeXappToken = module.exports.token
      next()
