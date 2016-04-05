#
# Inject common project-wide [view locals](http://expressjs.com/en/api.html#res.locals).
#

_ = require 'underscore'
_s = require 'underscore.string'
moment = require 'moment'
pickeeXappMiddlware = require './pickee-xapp-middleware'
Referrer = require 'referer-parser'
{ parse } = require 'url'

module.exports = (req, res, next) ->

  # Attach libraries to locals
  res.locals._s = _s
  res.locals.moment = moment

  # Pass the user agent into locals for data-useragent device detection
  res.locals.userAgent = req.get('user-agent')

  # Inject some project-wide sharify data such as the current path
  # and the xapp token.
  res.locals.sd.CURRENT_PATH = parse(req.url).pathname
  res.locals.sd.PICKEE_XAPP_TOKEN = pickeeXappMiddlware.token
  res.locals.sd.REFERRER = referrer = req.get 'Referrer'
  res.locals.sd.MEDIUM = new Referrer(referrer).medium if referrer

  next()
