Backbone = require 'backbone'
sinon = require 'sinon'
rewire = require 'rewire'
middleware = rewire '../../../lib/middleware/locals'

describe 'locals middleware', ->
  before ->
    @next = sinon.stub()

  it 'adds the user agent', ->
    middleware(
      req = { url: 'localhost:3000', get: -> 'foobar' },
      res = { locals: { sd: {} } },
      @next
    )
    res.locals.userAgent.should.equal 'foobar'

  it 'does not include query params in the current path', ->
    middleware(
      req = { url: 'localhost:3000/foo?bar=baz', get: -> 'foobar' },
      res = { locals: { sd: {} } },
      @next
    )
    res.locals.sd.CURRENT_PATH.should.equal '/foo'

  it 'adds the xapp token', ->
    middleware.__set__ 'pickeeXappMiddlware', { token: 'top-secret-token' }
    middleware(
      req = { url: 'localhost:3000/foo?bar=baz', get: -> 'foobar' },
      res = { locals: { sd: {} } },
      @next
    )
    res.locals.sd.PICKEE_XAPP_TOKEN.should.equal 'top-secret-token'

  it 'adds the referrer "medium"', ->
    middleware(
      req = { url: 'localhost:3000', get: -> 'https://www.google.com/' },
      res = { locals: { sd: {} } },
      @next
    )
    res.locals.sd.MEDIUM.should.equal 'search'
