sinon   = require 'sinon'
express = require 'express'
request = require 'superagent'
moment  = require 'moment'
pickeeXappMiddleware = require '../../../lib/middleware/pickee-xapp-middleware'

# Fake api server
api = express()
api.post '/tokens/xapp_token', (req, res, next) ->
  res.send { type: 'xapp_token', token: 'x-foo-token', expires_in: moment().add(2, 'seconds').format() }

# App server
app = express()
app.use pickeeXappMiddleware
  apiUrl: 'http://localhost:3001'
  clientId: 'fooid'
  clientSecret: 'foosecret'
app.get '/foo', (req, res) ->
  res.send res.locals.pickeeXappToken

describe 'pickeeXappMiddleware', ->

  before (done) ->
    api.listen 3001, ->
      app.listen 4001, ->
        done()

  it 'fetches an xapp token and stores it in the request', (done) ->
    request('http://localhost:4001/foo').end (err, res) ->
      res.text.should.equal 'x-foo-token'
      done()

  it 'injects the cached token on subsequent requests', (done) ->
    request('http://localhost:4001/foo').end (err, res) ->
      res.text.should.equal 'x-foo-token'
      done()

  it 'expires the token after the expiration time', (done) ->
    request('http://localhost:4001/foo').end (err, res) ->
      res.text.should.equal 'x-foo-token'
      setTimeout ->
        (pickeeXappMiddleware.token?).should.not.be.ok()
        done()
      , 2000
