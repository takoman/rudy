_         = require 'underscore'
Backbone  = require 'backbone'
rewire    = require 'rewire'
sinon     = require 'sinon'
should    = require 'should'

describe 'Pickee Passport', ->
  beforeEach ->
    # Every call of rewire() returns a new instance.
    @pickeePassport = rewire '../../../lib/middleware/pickee-passport.coffee'

  describe '#serializeUser', ->
    beforeEach ->
      _app = @pickeePassport({ userKeys: ['id', 'foo'] })
      @serializeUser = @pickeePassport.__get__ 'serializeUser'

    it 'only stores selected data in the session', (done) ->
      model = new Backbone.Model({ id: 'pickee', foo: 'baz', bam: 'bop' })
      model.fetch = (opts) -> opts.success()
      @serializeUser model, (err, userData) ->
        userData.should.be.eql { id: 'pickee', foo: 'baz' }
        userData.bam?.should.not.be.ok()
        done()

  describe '#onCreateUser', ->

    beforeEach ->
      @onCreateUser = @pickeePassport.__get__ 'onCreateUser'
      @next = sinon.stub()

    it 'calls the next middleware if user creation returns 201', ->
      @onCreateUser(@next)(null, status: 201)
      @next.calledOnce.should.be.ok()
      should(@next.args[0][0]).be.Undefined()

    it 'calls the error handling middleware if severe errors', ->
      @onCreateUser(@next)('error other than HTTP errors', null)
      @next.calledOnce.should.be.ok()
      @next.args[0][0].should.be.equal 'error other than HTTP errors'

    it 'calls the error handling middleware if HTTP errors', ->
      error = { status: 400, response: { body: 'something missing' } }
      @onCreateUser(@next)(error, null)
      @next.calledOnce.should.be.ok()
      @next.args[0][0].should.be.equal 'something missing'

  describe '#accessTokenCallback', ->
    beforeEach ->
      _app = @pickeePassport { CurrentUser: Backbone.Model }
      @accessTokenCallback = @pickeePassport.__get__ 'accessTokenCallback'
      @done = sinon.stub()

    it 'sets the user if no errors', ->
      @accessTokenCallback(@done)(null, { body: token: '1,2,4,8' })
      @done.calledOnce.should.be.ok()
      should(@done.args[0][0]).be.Null()
      @done.args[0][1].get('accessToken').should.be.equal '1,2,4,8'

    it 'sends a false user if HTTP errors', ->
      error = { status: 400, response: { body: 'something missing' } }
      @accessTokenCallback(@done)(error, null)
      @done.calledOnce.should.be.ok()
      should(@done.args[0][0]).be.Null()
      @done.args[0][1].should.be.false()
      @done.args[0][2].should.be.equal 'something missing'

    it 'sends error messages if severe errors', ->
      @accessTokenCallback(@done)('severe error', null)
      @done.calledOnce.should.be.ok()
      @done.args[0][0].should.be.equal 'severe error'
