_ = require 'underscore'
sinon = require 'sinon'
Backbone = require 'backbone'
routes = require '../routes'

describe 'Home routes', ->
  beforeEach ->
    sinon.stub Backbone, 'sync'
    @req = {}
    @res = { render: sinon.stub() }

  afterEach ->
    Backbone.sync.restore()

  describe '#index', ->
    it 'renders the index template', ->
      routes.index @req, @res
      @res.render.calledOnce.should.be.ok()
