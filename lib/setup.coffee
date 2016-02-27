#
# Sets up intial project settings, middleware, mounted apps, and
# global configuration such as overriding Backbone.sync and
# populating sharify data
#

{ API_URL, APP_NAME, APP_URL, CDN_URL, COOKIE_DOMAIN, NODE_ENV, PORT,
  S3_KEY, S3_SECRET, S3_BUCKET, S3_UPLOAD_DIR, PICKEE_ID, PICKEE_SECRET
} = config = require '../config'
express = require 'express'
Backbone = require 'backbone'
sharify = require 'sharify'
path = require 'path'
fs = require 'fs'
bucketAssets = require 'bucket-assets'
logger = require 'morgan'

module.exports = (app) ->

  # Inject some configuration & constant data into sharify
  sd = sharify.data =
    API_URL: config.API_URL
    NODE_ENV: config.NODE_ENV
    JS_EXT: (if 'production' is config.NODE_ENV then '.min.js' else '.js')
    CSS_EXT: (if 'production' is config.NODE_ENV then '.min.css' else '.css')

  # Override Backbone to use server-side sync
  Backbone.sync = require 'backbone-super-sync'

  # Mount sharify
  app.use sharify

  # Development only
  if 'development' is sd.NODE_ENV
    # Compile assets on request in development
    app.use require('stylus').middleware
      src: path.resolve(__dirname, '../')
      dest: path.resolve(__dirname, '../public')
    app.use require('browserify-dev-middleware')
      src: path.resolve(__dirname, '../')
      transforms: [require('jadeify'), require('caching-coffeeify')]

  # Test only
  if 'test' is sd.NODE_ENV
    # Mount fake API server
    app.use '/__api', require('../test/helpers/integration.coffee').api

  # General helpers and express middleware
  app.use bucketAssets()
  app.use logger('dev')

  # Mount apps
  app.use require '../apps/home'

  # Mount static middleware for sub apps, components, and project-wide
  fs.readdirSync(path.resolve __dirname, '../apps').forEach (fld) ->
    app.use express.static(path.resolve __dirname, "../apps/#{fld}/public")
  fs.readdirSync(path.resolve __dirname, '../components').forEach (fld) ->
    app.use express.static(path.resolve __dirname, "../components/#{fld}/public")
  app.use express.static(path.resolve __dirname, '../public')
