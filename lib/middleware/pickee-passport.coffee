#
# Uses [passport.js](http://passportjs.org/) to setup authentication with various
# providers like direct login with Rudy, or oauth signin with Facebook or Twitter.
#
# This middleware is merely responsible for authentication. That is, if a user
# successfully logs in or signs up, it will do its job (e.g. setting up sessions
# and storing the user in the locals) and pass on the request. Clients have to
# handle the rest of the request, e.g. responding with json data for ajax requests
# or redirecting to the home page for http requests. Similarly, if the
# authentication failed, it will call next(error) and let the error handling
# middleware catch and handle the errors.
#

_             = require 'underscore'
request       = require 'superagent'
express       = require 'express'
passport      = require 'passport'
qs            = require 'querystring'
{ parse }     = require 'url'
LocalStrategy = require('passport-local').Strategy
pickeeXapp    = require './pickee-xapp-middleware.coffee'


# Default configuration
config =
  loginPath  : '/users/login'
  signupPath : '/users/signup'
  userKeys   : ['id', 'name', 'email']

#
# Main function that overrides/injects any options, sets up passport, sets up an app to
# handle routing and injecting locals, and returns that app to be mounted as middleware.
#
module.exports = (options) ->
  module.exports.config = _.extend config, options
  initPassport()
  initApp()
  app

#
# Setup the mounted app that routes signup/login and injects necessary locals.
#
module.exports.app = app = express()

#
# Setup passport.
#
initPassport = ->
  passport.serializeUser serializeUser
  passport.deserializeUser deserializeUser
  passport.use new LocalStrategy { usernameField: 'email' }, localCallback

initApp = ->
  app.use passport.initialize()
  app.use passport.session()
  app.post config.loginPath, localAuth
  app.post config.signupPath, signup, localAuth
  app.use addLocals

#
# Authenticate a user with the local strategy we specified. Use custom
# callback to process the auth results manually. Note that when using a
# custom callback, it becomes the application's responsibility to establish
# a session (by calling req.login()) and send a response.
#
# https://github.com/jaredhanson/passport/blob/6bc59cb329ec1aebc028423d304b3f34f8112e60/lib/authenticator.js#L134-L155
# https://github.com/jaredhanson/passport-local/blob/c5a349b1fce71c51d66f78f8fc3e3861444b9a04/lib/strategy.js#L9-L41
# http://passportjs.org/docs#custom-callback
#
localAuth = (req, res, next) ->
  passport.authenticate('local', (err, user, info) ->
    return next(err) if err        # Severe erros
    return next(info) unless user  # Invalid login

    req.login(user, next)          # Successful login
  )(req, res, next)

#
# Local strategy callback to check the credentials
#
# After checking the credentials with `username` and `password`, call the
# `done` callback supplying a `user`, which should be set to `false` if the
# credentials are not valid. If an exception occurs, `err` should be set.
#
# Examples:
#   done(err)         # an exception occured
#   done(null, false) # the credentials are not valid
#   done(null, user)  # success
#
# https://github.com/jaredhanson/passport-local/blob/c5a349b1fce71c51d66f78f8fc3e3861444b9a04/lib/strategy.js#L9-L41
#
localCallback = (username, password, done) ->
  request
    .post "#{config.API_URL}/tokens/access_token"
    .type 'application/hal+json'
    .send
      client_id: config.PICKEE_ID
      client_secret: config.PICKEE_SECRET
      grant_type: 'credentials'
      email: username
      password: password
    .end accessTokenCallback(done)

#
# Returns the callback function for the superagent request object.
# Note that a 4xx or 5xx response with super agent are considered an error
# by default. Errors from such responses also contain an err.response field
# with all of the properties mentioned in "Response properties". Network
# failures, timeouts, and other errors that produce no response will contain
# no err.status or err.response fields.
#
# http://visionmedia.github.io/superagent/#error-handling
# http://visionmedia.github.io/superagent/#response-properties
#
accessTokenCallback = (done) ->
  (err, res) ->
    return done(null, false, err.response.body) if err and err.status # HTTP errors
    return done(err) if err # Other errors

    # No error, create the user with the access token
    done null, new config.CurrentUser(accessToken: res.body.token)

signup = (req, res, next) ->
  request
    .post "#{config.API_URL}/users"
    .set  'X-XAPP-TOKEN', pickeeXapp.token
    .type 'application/hal+json'
    .send user: {
      name: req.body.name
      email: req.body.email
      password: req.body.password
    }
    .end onCreateUser(next)

#
# Callback of submitting a user create request.
# If succeed, it will proceed to the next middleware, usually log in
# automatically. If failed, it will go to the next error handling middleware.
#
onCreateUser = (next) ->
  (err, res) ->
    return next(err.response.body) if err and err.status # HTTP errors
    return next(err) if err # Other errors
    next()

addLocals = (req, res, next) ->
  if req.user
    res.locals.user = req.user
    # so we can access user date, e.g. access token, client and server
    res.locals.sd?.CURRENT_USER = req.user.toJSON()
  next()

#
# Serialize user by fetching and caching user data in the session.
#
# To support persistent login sessions, Passport needs to be able to
# serialize users into and deserialize users out of the session.  Typically,
# this will be as simple as storing the user ID when serializing, and finding
# the user by ID when deserializing.
#
serializeUser = (user, done) ->
  user.fetch
    success: ->
      keys = ['accessToken'].concat config.userKeys
      done null, user.pick(keys)
    error: (model, res) ->
      # The res is a jqXHR object.
      # http://api.jquery.com/jQuery.ajax/#jqXHR
      done res

deserializeUser = (userData, done) ->
  done null, new config.CurrentUser(userData)
