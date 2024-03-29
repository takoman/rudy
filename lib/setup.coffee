#
# Sets up intial project settings, middleware, mounted apps, and
# global configuration such as overriding Backbone.sync and
# populating sharify data
#

{ API_URL, APP_NAME, APP_URL, CDN_URL, COOKIE_DOMAIN, NODE_ENV, PORT,
  S3_KEY, S3_SECRET, S3_BUCKET, S3_UPLOAD_DIR, PICKEE_ID, PICKEE_SECRET
  SESSION_SECRET, SESSION_COOKIE_MAX_AGE, COOKIE_DOMAIN, SESSION_COOKIE_KEY
} = config = require '../config'
_                   = require 'underscore'
express             = require 'express'
Backbone            = require 'backbone'
sharify             = require 'sharify'
path                = require 'path'
fs                  = require 'fs'
bucketAssets        = require 'bucket-assets'
bodyParser          = require 'body-parser'
cookieParser        = require 'cookie-parser'
session             = require 'cookie-session'
logger              = require 'morgan'
localsMiddleware    = require './middleware/locals'
ensureSSL           = require './middleware/ensure_ssl'
pickeePassport      = require './middleware/pickee-passport'
pickeeXappMiddlware = require './middleware/pickee-xapp-middleware'

module.exports = (app) ->

  # Inject some configuration & constant data into sharify
  sd = sharify.data =
    API_URL: config.API_URL
    NODE_ENV: config.NODE_ENV
    JS_EXT: (if 'production' is config.NODE_ENV then '.min.js' else '.js')
    CSS_EXT: (if 'production' is config.NODE_ENV then '.min.css' else '.css')

  # CurrentUser must be defined after setting sharify.data
  CurrentUser = require '../models/current_user'

  # Override Backbone to use server-side sync, inject the XAPP token,
  # add redis caching, and augment sync with Q promises.
  sync = require "backbone-super-sync"
  # sync.timeout = API_REQUEST_TIMEOUT
  # sync.cacheClient = cache.client
  # sync.defaultCacheTime = DEFAULT_CACHE_TIME
  Backbone.sync = (method, model, options) ->
    options.headers ?= {}
    options.headers['X-XAPP-TOKEN'] = pickeeXappMiddlware.token or ''
    sync method, model, options

  # Mount sharify
  app.use sharify

  # Development only
  if 'development' is sd.NODE_ENV
    # Compile assets on request in development
    bootstrap = require 'bootstrap-styl'
    stylus = require 'stylus'
    compile = (str, path) ->
      stylus(str)
        .set('filename', path)
        .set('include css', true)
        .use(bootstrap())
    app.use stylus.middleware
      src: path.resolve(__dirname, '../')
      dest: path.resolve(__dirname, '../public')
      compile: compile
    app.use require('browserify-dev-middleware')
      src: path.resolve(__dirname, '../')
      transforms: [require('jadeify'), require('caching-coffeeify')]

  # Test only
  if 'test' is sd.NODE_ENV
    # Mount fake API server
    app.use '/__api', require('../test/helpers/integration.coffee').api

  app.use pickeeXappMiddlware(
    apiUrl: API_URL
    clientId: PICKEE_ID
    clientSecret: PICKEE_SECRET
  ) unless 'test' is NODE_ENV

  # Setup Passport middleware for authentication along with the
  # body/cookie parsing middleware needed for that.
  app.use bodyParser.json()
  app.use bodyParser.urlencoded extended: true
  app.use session
    cookie: secure: true
    secret: SESSION_SECRET
    domain: COOKIE_DOMAIN
    key: SESSION_COOKIE_KEY
    maxage: SESSION_COOKIE_MAX_AGE
    # secure uses req.connection.encrypted, but heroku has nginx terminating SSL
    # secureProxy just sets secure=true
    secureProxy: "production" is NODE_ENV or "staging" is NODE_ENV

  app.use pickeePassport
    API_URL: API_URL
    PICKEE_ID: PICKEE_ID
    PICKEE_SECRET: PICKEE_SECRET
    CurrentUser: CurrentUser

  # Proxy / redirect requests before they even have to deal with Rudy routing
  app.use ensureSSL

  # General helpers and express middleware
  app.use bucketAssets()
  app.use localsMiddleware
  app.use logger('dev')

  # Mount apps
  app.use require '../apps/home'
  app.use require '../apps/auth'
  app.use require '../apps/style_guide'

  # Mount static middleware for sub apps, components, and project-wide
  fs.readdirSync(path.resolve __dirname, '../apps').forEach (fld) ->
    app.use express.static(path.resolve __dirname, "../apps/#{fld}/public")
  fs.readdirSync(path.resolve __dirname, '../components').forEach (fld) ->
    app.use express.static(path.resolve __dirname, "../components/#{fld}/public")
  app.use express.static(path.resolve __dirname, '../public')
